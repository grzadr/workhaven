#!/bin/bash

set -eux

DATE_TAG=$(date '+%y-%m-%d')
IMAGE_TAG=${1:-${DATE_TAG}}

IMAGE_NAME="grzadr/workhaven"
python3 update_readme.py
docker build --pull \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"

