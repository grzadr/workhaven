#!/bin/bash

set -eux
set -o pipefail

IMAGE_NAME="grzadr/workhaven"

DATE_TAG=$(date '+%F')
IMAGE_TAG=${1:-${DATE_TAG}}

docker push "${IMAGE_NAME}:${IMAGE_TAG}"
docker push "${IMAGE_NAME}:latest"
