Docker Kafka Zookeeper ![Build Status](https://travis-ci.org/terascope/docker-kafka-zookeeper.svg?branch=master)
======================
Docker image for Kafka message broker including Zookeeper

Run container
-------------
```
docker run -p 2181:2181 -p 9092:9092 -e ADVERTISED_HOST=localhost terascope/kafka-zookeeper:2.11-1.1.0
```

Test
----
Run Kafka console consumer
```
kafka-console-consumer --bootstrap-server localhost:9092 --topic test
```

Run Kafka console producer
```
kafka-console-producer --broker-list localhost:9092 --topic test
test1
test2
test3
```

Verify that messages have been received in console consumer
```
test1
test2
test3
```

Get from Dockerhub
------------------
https://hub.docker.com/r/terascope/docker-kafka-zookeeper/

Credits
-------
Originally cloned and inspired by https://github.com/hey-johnnypark/docker-kafka-zookeeper and https://github.com/spotify/docker-kafka.
