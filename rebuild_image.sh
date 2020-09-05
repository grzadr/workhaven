#!/bin/bash

set -eux

DATE_TAG=$(date '+%F')
IMAGE_TAG=${1:-${DATE_TAG}}

sed -i.old "s/LABEL version=[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/LABEL version=${IMAGE_TAG}/" Dockerfile

exit 0

IMAGE_NAME="grzadr/workhaven"
python3 update_readme.py
docker build --pull \
  -t "${IMAGE_NAME}:${IMAGE_TAG}" \
  .

docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:latest"

