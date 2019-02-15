FROM ubuntu:18.04

RUN apt-get update -y
RUN apt-get install mysql-server openjdk-8-jdk -y

COPY ./myapp.cnf /etc/mysql/

WORKDIR /data

CMD tail -f /dev/null
