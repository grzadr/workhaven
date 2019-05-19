#!/bin/bash

set -eux

IMAGE_NAME="grzadr/workhaven"
#DATE_TAG=$(date '+%y-%m-%d')
DATE_TAG="{1}"

docker push "${IMAGE_NAME}":latest
docker push "${IMAGE_NAME}":"${DATE_TAG}"
