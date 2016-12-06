#!/bin/bash

set -x
set -e

docker run -v `pwd`:/pytz -v ~/.gitconfig:/root/.gitconfig --rm -ti ubuntu bash -c '
apt-get update
apt-get install git make -y
cd /pytz/

make sync TAG=2016j
'
