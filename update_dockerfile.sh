#!/bin/bash

set -eux
set -o pipefail

docker pull -q jupyter/minimal-notebook:latest > /dev/null

NEW_TAG=$(docker images --format "{{.Repository}}|{{.Digest}}|{{.CreatedAt}}" | grep "^jupyter/minimal-notebook|" | sort -t '|' -k 3 -r | head -n 1 | cut -d'|' -f 2)

sed -i'.old' "s_FROM jupyter/minimal-notebook@sha256:[a-z0-9]*_FROM jupyter/minimal-notebook@${NEW_TAG}_" Dockerfile
