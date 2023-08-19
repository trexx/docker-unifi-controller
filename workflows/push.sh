#!/usr/bin/env bash

. "../env"

docker push "$DOCKER_REPO:$UNIFI_CONTROLLER_VERSION"