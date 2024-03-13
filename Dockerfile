FROM busybox:1-uclibc AS downloader

ENV UNIFI_CONTROLLER_VERSION "8.0.28"
ENV MONGODB_VERSION "3.6.23"

RUN wget -O- https://dl.ui.com/unifi/${UNIFI_CONTROLLER_VERSION}/UniFi.unix.zip | unzip -qd /tmp -
RUN wget -O- https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGODB_VERSION}.tgz | tar -zx mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod -C /tmp
RUN mv /tmp/mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod /tmp/UniFi/bin/mongod

FROM gcr.io/distroless/java17-debian12:latest@sha256:9008a52842724ed0d6fa5c87050a8477d11656449f5f5acef961cade3e3e46a3
LABEL org.opencontainers.image.source https://github.com/trexx/docker-unifi-controller

COPY --from=downloader --link /tmp/UniFi /app

WORKDIR /app

EXPOSE 8080/tcp 8443/tcp
CMD ["-Dfile.encoding=UTF-8", \
    "--add-opens=java.base/java.lang=ALL-UNNAMED", \
    "--add-opens=java.base/java.time=ALL-UNNAMED", \
    "--add-opens=java.base/sun.security.util=ALL-UNNAMED", \
    "--add-opens=java.base/java.io=ALL-UNNAMED", \
    "--add-opens=java.rmi/sun.rmi.transport=ALL-UNNAMED", \
    "-XX:+UseParallelGC", \
    "-XX:-UsePerfData", \
    "-XX:+ExitOnOutOfMemoryError", \
    "-jar", \
    "/app/lib/ace.jar", \
    "start"]
