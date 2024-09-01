#!/bin/bash
set -e
cd ${0%/*}/..
./script/docker_build.sh
docker compose push