#!/bin/bash

set -eux
set -o pipefail

while getopts 'v:l:p:n:c:' OPTION; do
  case "$OPTION" in
    l)
      ARG_LABEL="$OPTARG"
            echo "LABEL: '$OPTARG'"
      ;;
    v)
      ARG_VOLUME="$OPTARG"
      echo "VOLUME: '$ARG_VOLUME'"
      ;;
    p)
      ARG_PORT="$OPTARG"
      echo "PORT: '$ARG_PORT'"
      ;;
    n)
      ARG_NAME="$OPTARG"
      echo "NAME: $ARG_NAME"
      ;;
    c)
      ARG_COMMAND="$OPTARG"
      echo "COMMAND: '$ARG_COMMAND'"
      ;;
    ?)
      echo "script usage: $(basename $0) [-l label] [-v volume] [-p port] [-c command]" >&2
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

JUPYTER_NAME="${ARG_NAME:-Jupyter}"
JUPYTER_PORT=${ARG_PORT:-8888}
JUPYTER_VOLUME="${ARG_VOLUME:-$(pwd)}"
JUPYTER_LABEL="${ARG_LABEL:-latest}"
JUPYTER_COMMAND="${ARG_COMMAND:-}"

if [ -n "$JUPYTER_COMMAND" ]; then
  JUPYTER_COMMAND="/bin/bash -c ${JUPYTER_COMMAND}"
fi

# if (( $# > 0)); then
#   JUPYTER_BACKGROUND=""
# else
#   JUPYTER_BACKGROUND=" -d"
# fi

docker run -it \
  -p ${JUPYTER_PORT}:8888 \
  -v ${JUPYTER_VOLUME}:/home/jovyan/data \
  --name ${JUPYTER_NAME} \
  --rm \
  --workdir /home/jovyan/data \
  grzadr/workhaven:${JUPYTER_LABEL} \
  `${JUPYTER_COMMAND}`
