FROM busybox:1-uclibc@sha256:23deb35184aeb204224e6307f9c82a26f87059a5c9f476c797ba28f357e5df6d AS downloader

ENV UNIFI_CONTROLLER_VERSION="10.5.67-y6o74ax798"
ENV MONGODB_VERSION="3.6.23"

RUN wget -O- https://dl.ui.com/unifi/${UNIFI_CONTROLLER_VERSION}/UniFi.unix.zip | unzip -qd /tmp -
RUN wget -O- https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-${MONGODB_VERSION}.tgz | tar -zx mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod -C /tmp/UniFi/bin mongodb-linux-x86_64-${MONGODB_VERSION}/bin/mongod --strip-components=2

FROM gcr.io/distroless/java25-debian13@sha256:73f2263db8defa233004a7c700fd81e25c8747a530c413bddf74367b68663468 AS compile
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
