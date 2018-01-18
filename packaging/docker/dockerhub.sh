#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build -t openhie/openinfoman .
docker tag -f openhie/openinfoman:$(git rev-parse --short HEAD) openhie/openinfoman:latest
docker push openhie/openinfoman:$(git rev-parse --short HEAD)
docker push openhie/openinfoman:latest