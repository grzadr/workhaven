#!/bin/bash

set -eux

docker run -it "grzadr/workhaven:${1:-latest}" condaup --dry-run
