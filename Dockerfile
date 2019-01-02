FROM openjdk:8-jdk-alpine

RUN set -o errexit -o nounset \
  && echo "Installing MySQL and MySQL Client" \
  && addgroup -S -g 500 mysql \
  && adduser -S -D -H -u 500 -G mysql -g "MySQL" mysql \
  && apk add --no-cache bash mysql mysql-client \
  && mkdir /scripts

COPY ./scripts/start.sh /scripts/start.sh
RUN chmod 744 /scripts/start.sh

ENTRYPOINT [ "/scripts/start.sh" ]


