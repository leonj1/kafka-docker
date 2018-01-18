#!/bin/bash -x

# Source: https://github.com/wurstmeister/kafka-docker
# KAFKA_CREATE_TOPICS: "Topic1:1:3,Topic2:1:1:compact"
# Topic 1 will have 1 partition and 3 replicas, Topic 2 will have 1 partition, 1 replica and a cleanup.policy set to compact

if [[ -z "$KAFKA_PORT" ]]; then
    export KAFKA_PORT=9092
fi

if [[ -z "$KAFKA_BROKER_ID" ]]; then
    # By default auto allocate broker ID
    export KAFKA_BROKER_ID=-1
fi

if [[ -z "$KAFKA_LOG_DIRS" ]]; then
    #export KAFKA_LOG_DIRS="/kafka/kafka-logs-$HOSTNAME"
    export KAFKA_LOG_DIRS=/logs
fi

# This is required
if [[ -z "$KAFKA_ZOOKEEPER_CONNECT" ]]; then
    export KAFKA_ZOOKEEPER_CONNECT=$(env | grep ZK.*PORT_2181_TCP= | sed -e 's|.*tcp://||' | paste -sd ,)
fi

if [[ -n "$KAFKA_HEAP_OPTS" ]]; then
    sed -r -i "s/(export KAFKA_HEAP_OPTS)=\"(.*)\"/\1=\"$KAFKA_HEAP_OPTS\"/g" $KAFKA_HOME/bin/kafka-server-start.sh
    unset KAFKA_HEAP_OPTS
fi

rm -rf /tmp/server.properties
cp $KAFKA_HOME/config/server.properties /tmp/server.properties

for VAR in `env`
do
  if [[ $VAR =~ ^KAFKA_ && ! $VAR =~ ^KAFKA_HOME ]]; then
    kafka_name=`echo "$VAR" | sed -r "s/KAFKA_(.*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
    env_var=`echo "$VAR" | sed -r "s/(.*)=.*/\1/g"`
    if egrep -q "(^|^#)$kafka_name=" $KAFKA_HOME/config/server.properties; then
        echo  kafka_name is $kafka_name AND env_var1 is ${!env_var}
        sed -r -i "s@(^|^#)($kafka_name)=(.*)@\2=${!env_var}@g" $KAFKA_HOME/config/server.properties #note that no config values may contain an '@' char
    else
        echo  kafka_name is $kafka_name AND env_var2 is ${!env_var}
        echo "$kafka_name=${!env_var}" >> $KAFKA_HOME/config/server.properties
    fi
  fi
done

echo Diffing scripts
diff /tmp/server.properties $KAFKA_HOME/config/server.properties

if [[ -n "$CUSTOM_INIT_SCRIPT" ]] ; then
  eval $CUSTOM_INIT_SCRIPT
fi


KAFKA_PID=0

# see https://medium.com/@gchudnov/trapping-signals-in-docker-containers-7a57fdda7d86#.bh35ir4u5
term_handler() {
  echo 'Stopping Kafka....'
  if [ $KAFKA_PID -ne 0 ]; then
    kill -s TERM "$KAFKA_PID"
    wait "$KAFKA_PID"
  fi
  echo 'Kafka stopped.'
  exit
}


# Capture kill requests to stop properly
trap "term_handler" SIGHUP SIGINT SIGTERM

if [ ! -z "$KAFKA_CREATE_TOPICS" ]; then
  create-topics.sh &
fi
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties &
KAFKA_PID=$!

wait
