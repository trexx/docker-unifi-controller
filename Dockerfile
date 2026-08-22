FROM busybox:1-uclibc@sha256:23deb35184aeb204224e6307f9c82a26f87059a5c9f476c797ba28f357e5df6d AS downloader

ENV UNIFI_CONTROLLER_VERSION="10.6.97"
ENV MONGODB_VERSION="3.6.23"

RUN wget -O- https://dl.ui.com/unifi/${UNIFI_CONTROLLER_VERSION}/UniFi.unix.zip | unzip -qd /tmp -
RUN wget -O- https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGODB_VERSION}.tgz | tar -zx mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod -C /tmp/UniFi/bin mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod --strip-components=2

FROM gcr.io/distroless/java25-debian13@sha256:d4885eb64f80c66ad40b12bb38e4adb57df715cd6625bd1b826ee2a08408d6b5 AS compile
LABEL org.opencontainers.image.source="https://github.com/trexx/docker-unifi-controller"

COPY --from=downloader --link /tmp/UniFi /app

WORKDIR /app

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
