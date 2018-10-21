#!/bin/bash

## Usage
#  ./run-bigdl-docker.sh   <image name>  [optional command]
#
#  ./run-bigdl-docker.sh  intel/bigdl
#
#  or during developing, give a local docker image id
#  ./run-bigdl-docker.sh  abcd1234
#
#  provide an optional command, here is an example of simple bash
#  ./run-bigdl-docker.sh  abcd1234  bash

if [ -z "$1" ] ; then
    echo "Usage:  $0    <image name>    [optional command]"
    echo "Missing Docker image id.  exiting"
    exit -1
fi

image_id="$1"
cmd="$2"

# mount the current directory at /home/jovyan/work
this="${BASH_SOURCE-$0}"
#mydir=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
mydir=$(pwd -P)

## ports:
##  4040-4050 : Spark UI
##  8888-8890 : Jupyter UI
##  6006  : Tensorboard UI

docker run -it   \
    -p 4040-4050:4040-4050 \
    -p 8888-8890:8888-8890 \
    -p 6006:6006 \
    -v"$mydir:/home/jovyan/work" \
    "$image_id" \
    ${cmd}
