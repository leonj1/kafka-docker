# My Dockerized Kafka
docker run  -d --name kafka -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181 -e HOSTNAME_COMMAND="/usr/bin/get_host_public_ip.sh" -e KAFKA_CREATE_TOPICS="doctor_questions:1:1,doctor_response:1:1,admin_feedback:1:1" --net=host jose/kafka:10.01.20170322
# Kafka Consumer Example
/opt/kafka_2.11-0.10.0.1/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic admin_feedback --from-beginning 
# Clear topic by reducing the retention period
/opt/kafka_2.11-0.10.0.1/bin/kafka-configs.sh --zookeeper localhost:2181 --entity-type topics --alter --add-config retention.ms=1000 --entity-name admin_feedback

# OSX Get Docker daemon public ip
ifconfig en1 | grep "inet " | cut -d " " -f2

