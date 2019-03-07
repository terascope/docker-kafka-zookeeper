#!/bin/sh

set -e

ZOOKEEPER_CONFIG="$KAFKA_HOME/config/zookeeper.properties"

sed -r -i "s/(clientPort)=(.*)/\\1=${ZOOKEEPER_PORT:-2181}/g" "$ZOOKEEPER_CONFIG"

# Run zookeeper
"zookeeper-server-start.sh" "$ZOOKEEPER_CONFIG"
