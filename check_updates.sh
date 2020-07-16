#!/bin/bash

set -eux
set -o pipefail

CONTAINER_NAME="workhaven_check_updates"

docker run --name ${CONTAINER_NAME} --rm -it "grzadr/workhaven:${1:-latest}" condaup --dry-run --json | \
grep -Pzo -e '\"LINK\"\:\s+\[([^\]]+)\]' | \
head -n -1 | \
tail -n +2 | \
awk '
BEGIN{
  RS="\\s+},\\s+"; 
  FS = "\n";
}
{
    match($7, "\"name\":\\s+\"(\\S+)\"", matched);
    name = matched[1];
    
    match($9, "\"version\":\\s+\"(\\S+)\"", matched);
    version=matched[1];
    
    print name "=" version;
    next;
}
' | awk '
BEGIN{
  RS = "\n"; 
  FS = "=";
}
FNR==NR {
  registry[$1] = $2
  next;
}
/^#/{ print $0; next }
!length($0) {print $0; next}
{
  if ($1 in registry){print $1 "=" registry[$1]} else {print $0}
}
' - packages/conda.list > packages/conda.list.new

