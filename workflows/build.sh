#!/usr/bin/env bash

. "../env"

docker build \
	--build-arg "UNIFI_CONTROLLER_VERSION=$UNIFI_CONTROLLER_VERSION" \
	--build-arg "MONGODB_VERSION=$MONGODB_VERSION" \
	--tag "$DOCKER_REPO:$UNIFI_CONTROLLER_VERSION" \
    "../"