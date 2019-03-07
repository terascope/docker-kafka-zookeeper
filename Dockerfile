# Kafka and Zookeeper

FROM java:openjdk-8-jre-alpine

RUN apk add --no-cache bash wget supervisor

RUN mkdir -p /opt && chmod 755 /opt

ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 2.1.0
ENV KAFKA_HOME /opt/kafka
ENV KAFKA_NAME kafka_"$SCALA_VERSION"-"$KAFKA_VERSION"
ENV KAFKA_DOWNLOAD_URL https://www.apache.org/dist/kafka/"$KAFKA_VERSION"/"$KAFKA_NAME".tgz
ENV PATH ${PATH}:${KAFKA_HOME}/bin

WORKDIR /tmp

RUN wget -q $KAFKA_DOWNLOAD_URL -O /tmp/"$KAFKA_NAME".tgz \
    && tar xfz "$KAFKA_NAME".tgz \
    && mv "$KAFKA_NAME" /opt/kafka \
    && rm "$KAFKA_NAME".tgz

WORKDIR /

ADD assets/scripts/start-kafka.sh /usr/bin/start-kafka.sh
ADD assets/scripts/start-zookeeper.sh /usr/bin/start-zookeeper.sh

# Supervisor config
ADD assets/supervisor/*.ini /etc/supervisor.d/

VOLUME ["/kafka", "/zookeeper"]

# 2181 is zookeeper, 9092 is kafka
EXPOSE 2181 9092

ENV KAFKA_HEAP_OPTS "-Xmx512M -Xms512M"
ENV KAFKA_JVM_PERFORMANCE_OPTS "-server -XX:+UseCompressedOops -XX:+UseParNewGC -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+CMSScavengeBeforeRemark -XX:+DisableExplicitGC -Djava.awt.headless=true"

CMD ["supervisord", "-n"]
