FROM alpine:3.18 AS downloader

ARG UNIFI_CONTROLLER_VERSION
ENV UNIFI_CONTROLLER_VERSION "$UNIFI_CONTROLLER_VERSION"
ARG MONGODB_VERSION
ENV MONGODB_VERSION "$MONGODB_VERSION"

RUN apk add --upgrade --no-cache dpkg
RUN wget -O /tmp/unifi_sysvinit_all.deb https://dl.ui.com/unifi/${UNIFI_CONTROLLER_VERSION}/unifi_sysvinit_all.deb
RUN dpkg-deb -xv /tmp/unifi_sysvinit_all.deb /tmp

RUN wget -O /tmp/mongodb-linux.tgz https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGODB_VERSION}.tgz
RUN tar -zxf /tmp/mongodb-linux.tgz mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod -C /tmp
RUN mv mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod /tmp/usr/lib/unifi/bin/mongod

FROM amazoncorretto:11
LABEL org.opencontainers.image.source https://github.com/trexx/docker-unifi-controller

COPY --from=downloader --link /tmp/usr/lib/unifi /app

WORKDIR /app

EXPOSE 8080/tcp 8443/tcp
CMD ["/usr/bin/java", "-XX:-UsePerfData", "-jar", "/app/lib/ace.jar", "start"]