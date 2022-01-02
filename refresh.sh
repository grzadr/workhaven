#!/bin/bash

set -eux

check_updates.sh && rebuild_image.sh && push_images.sh

