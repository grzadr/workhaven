#!/bin/bash

set -eux
set -o pipefail

IMAGE_NAME="grzadr/workhaven"

DATE_TAG=$(date '+%y-%m-%d')
IMAGE_TAG=${1:-${DATE_TAG}}

docker push "${IMAGE_NAME}:${IMAGE_TAG}"

docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"
docker push "${IMAGE_NAME}:latest"
