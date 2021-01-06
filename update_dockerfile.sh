#!/bin/bash

set -eux
set -o pipefail

docker pull -q jupyter/minimal-notebook:latest > /dev/null

NEW_TAG=$(docker images --format "{{.ID}}|{{.CreatedAt}}" | sort -t '|' -k 2 -r | head -n 1 | cut -d'|' -f 1)

sed -i'.old' "s_FROM jupyter/minimal-notebook:[a-z0-9]*_FROM jupyter/minimal-notebook:${NEW_TAG}_" Dockerfile
