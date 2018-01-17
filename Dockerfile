FROM ubuntu:14.04

RUN apt-get -qq update &&\
    apt-get install -y unzip wget curl docker jq coreutils vim lsof

ENV KAFKA_VERSION="1.0.0" SCALA_VERSION="2.11"
ADD kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz /tmp
RUN mv /tmp/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION}
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh
ADD get_host_public_ip.sh /usr/bin/get_host_public_ip.sh

RUN mkdir /logs

ADD jdk-8u121-linux-x64.tar.gz /
RUN ln -s /jdk1.8.0_121 /jdk
ENV JAVA_HOME /jdk
RUN apt-get install -y telnet
ENV TERM=xterm

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["/usr/bin/start-kafka.sh"]

