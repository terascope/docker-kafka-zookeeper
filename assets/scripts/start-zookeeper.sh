#!/bin/sh

set -e

if [ -n "$ZOOKEEPER_PORT" ]; then
    sed -r -i "s/(clientPort)=(.*)/\\1=$ZOOKEEPER_PORT/g" "$ZOOKEEPER_HOME/conf/zoo.cfg"
fi

"$ZOOKEEPER_HOME/bin/zkServer.sh" start-foreground
