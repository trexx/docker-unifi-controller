#!/usr/bin/env bash

. "./env"

docker run \
	--publish "8080:8080" \
	--publish "8443:8443" \
	--rm \
	"$DOCKER_REPO:$UNIFI_CONTROLLER_VERSION"