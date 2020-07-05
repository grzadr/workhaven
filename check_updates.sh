#!/bin/bash

set -eux
set -o pipefail

CONTAINER_NAME="workhaven_check_updates"

docker run --name ${CONTAINER_NAME} --rm -it "grzadr/workhaven:${1:-latest}" condaup --dry-run

