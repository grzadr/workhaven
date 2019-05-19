#!/bin/bash

set -eux

DATE_TAG=$(date '+%y-%m-%d')
IMAGE_TAG=${1:-${DATE_TAG}}
DO_PUSH=${2:-"yes"}

IMAGE_NAME="grzadr/workhaven"
python3 update_readme.py
docker build --pull \
  --build-arg image_label="${IMAGE_TAG}" \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

if [[ ${DO_PUSH} == "yes" ]]; then
  docker push "${IMAGE_NAME}:${IMAGE_TAG}"
fi
