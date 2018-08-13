#!/usr/bin/env bash
set -ex

# automate tagging with the short commit hash
docker build --no-cache -t openhie/openinfoman:$(git rev-parse --short HEAD) .
docker tag openhie/openinfoman:$(git rev-parse --short HEAD) openhie/openinfoman:latest
docker push openhie/openinfoman:$(git rev-parse --short HEAD)
docker push openhie/openinfoman:latest