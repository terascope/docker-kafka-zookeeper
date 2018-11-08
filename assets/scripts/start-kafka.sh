#!/bin/sh

set -e

# Optional ENV variables:
# * ADVERTISED_HOST: the external ip for the container, e.g. `docker-machine ip \`docker-machine active\``
# * ADVERTISED_PORT: the external port for Kafka, e.g. 9092
# * ZK_CHROOT: the zookeeper chroot that's used by Kafka (without / prefix), e.g. "kafka"
# * LOG_RETENTION_HOURS: the minimum age of a log file in hours to be eligible for deletion (default is 168, for 1 week)
# * LOG_RETENTION_BYTES: configure the size at which segments are pruned from the log, (default is 1073741824, for 1GB)
# * NUM_PARTITIONS: configure the default number of log partitions per topic

BROKER_PORT="${ADVERTISED_PORT:-9092}"
SERVER_CONFIG="$KAFKA_HOME/config/server.properties"

if [ -n "$ADVERTISED_PORT" ] || [ -n "$ADVERTISED_HOST" ]; then
    echo "setting advertised and port: $ADVERTISED_HOST:$BROKER_PORT"
    {
        printf "\\nadvertised.port = %s" "$BROKER_PORT"
        printf "\\nlisteners = INSIDE://:9092,OUTSIDE://:%s" "$ADVERTISED_HOST" "$BROKER_PORT"
        printf "\\nadvertised.listeners = INSIDE://:9092,OUTSIDE://%s:%s" "$ADVERTISED_HOST" "$BROKER_PORT" 
        printf "\\nlistener.security.protocol.map = INSIDE:PLAINTEXT,OUTSIDE:PLAINTEXT"
        printf "\\ninter.broker.listener.name = INSIDE"
    } >> "$SERVER_CONFIG"
fi

{
    printf "\\ngroup.min.session.timeout.ms = 1000"
    printf "\\nzookeeper.session.timeout.ms = 5000"
    printf "\\nzookeeper.connection.timeout.ms = 1000"
} >> "$SERVER_CONFIG"

# Set the zookeeper chroot
if [ ! -z "$ZK_CHROOT" ]; then
    # wait for zookeeper to start up
    until /usr/share/zookeeper/bin/zkServer.sh status; do
      sleep 0.1
    done

    # create the chroot node
    echo "create /$ZK_CHROOT \"\"" | /usr/share/zookeeper/bin/zkCli.sh || {
        echo "can't create chroot in zookeeper, exit"
        exit 1
    }

    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\\1=localhost:$ZOOKEEPER_PORT\\/$ZK_CHROOT/g" "$SERVER_CONFIG"
else
    # configure kafka
    sed -r -i "s/(zookeeper.connect)=(.*)/\\1=localhost:${ZOOKEEPER_PORT:-2181}/g" "$SERVER_CONFIG"
fi

sed -r -i "s/(log.retention.hours)=(.*)/\\1=${LOG_RETENTION_HOURS:-1}/g" "$SERVER_CONFIG"

if [ ! -z "$LOG_RETENTION_BYTES" ]; then
    echo "log retention bytes: $LOG_RETENTION_BYTES"
    sed -r -i "s/#(log.retention.bytes)=(.*)/\\1=$LOG_RETENTION_BYTES/g" "$SERVER_CONFIG"
fi

sed -r -i "s/(num.partitions)=(.*)/\\1=${NUM_PARTITIONS:-1}/g" "$SERVER_CONFIG"
printf "\\nauto.create.topics.enable=%s" "${AUTO_CREATE_TOPICS:-true}" >> "$SERVER_CONFIG"

# Run Kafka
"$KAFKA_HOME/bin/kafka-server-start.sh" "$SERVER_CONFIG"
