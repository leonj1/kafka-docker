FROM anapsix/alpine-java

MAINTAINER Jose Leon <leonj1@gmail.com>

RUN apk update && \
    apk add bash bash-doc bash-completion mysql-client heimdal-telnet

ENV KA_VERSION="1.0.0" SCALA_VERSION="2.11"
ADD kafka_${SCALA_VERSION}-${KA_VERSION}.tgz /tmp
RUN mv /tmp/kafka_${SCALA_VERSION}-${KA_VERSION} /opt

VOLUME ["/kafka"]

ENV KAFKA_HOME /opt/kafka_${SCALA_VERSION}-${KA_VERSION}
ADD start-kafka.sh /usr/bin/start-kafka.sh
ADD broker-list.sh /usr/bin/broker-list.sh
ADD create-topics.sh /usr/bin/create-topics.sh
ADD get_host_public_ip.sh /usr/bin/get_host_public_ip.sh

RUN mkdir /logs

#ENV JAVA_HOME /jdk
ENV TERM=xterm

# Use "exec" form so that it runs as PID 1 (useful for graceful shutdown)
CMD ["/usr/bin/start-kafka.sh"]

