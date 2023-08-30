#!/usr/bin/env bash

. "../env"

docker build \
	--build-arg "TAG=$TAG" \
	--tag "$DOCKER_REPO:$TAG" \
    "../"