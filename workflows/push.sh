#!/usr/bin/env bash

. "../env"

docker push "$DOCKER_REPO:$TAG"