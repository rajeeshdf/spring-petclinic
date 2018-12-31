FROM openjdk:8-jdk-alpine

ENV GRADLE_HOME /opt/gradle
ENV GRADLE_VERSION 4.10.3

ARG GRADLE_DOWNLOAD_SHA256=8626cbf206b4e201ade7b87779090690447054bc93f052954c78480fa6ed186e
RUN set -o errexit -o nounset \
    && apk update \
	&& echo "Installing build dependencies" \
	&& apk add --no-cache --virtual .build-deps \
		ca-certificates \
		openssl \
		unzip \
		bash \
	\
	&& echo "Downloading Gradle" \
	&& wget -O gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum -c - \
	\
	&& echo "Installing Gradle" \
	&& unzip gradle.zip \
	&& rm gradle.zip \
	&& mkdir /opt \
	&& mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
	&& ln -s "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
	\
	&& apk del .build-deps \
	\
	&& echo "Adding gradle user and group" \
	&& addgroup -S -g 1000 gradle \
	&& adduser -D -S -G gradle -u 1000 -s /bin/ash gradle \
	&& mkdir /home/gradle/.gradle \
	&& chown -R gradle:gradle /home/gradle \
	&& apk add --no-cache bash \
	\
	&& echo "Symlinking root Gradle cache to gradle Gradle cache" \
	&& ln -s /home/gradle/.gradle /root/.gradle

RUN set -o errexit -o nounset \
  && echo "Installing MySQL and MySQL Client" \
  && addgroup -S -g 500 mysql \
  && adduser -S -D -H -u 500 -G mysql -g "MySQL" mysql \
  && apk add --no-cache mysql mysql-client \
  && mkdir /scripts

COPY ./scripts/start.sh /scripts/start.sh
RUN chmod 744 /scripts/start.sh

ENTRYPOINT [ "/scripts/start.sh" ]


