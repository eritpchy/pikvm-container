#!/bin/bash
set -e
cd ${0%/*}/..
source .env || true
PROJECT_NAME="$(basename -a $PWD)"
./script/docker_publish.sh
ssh $REMOTE_USER@$REMOTE_HOST mkdir -p $REMOTE_DIR/$PROJECT_NAME
rsync --no-perms --no-owner --no-group --omit-dir-times --exclude-from=.rsyncignore \
    -vrPs $(pwd)/ $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$PROJECT_NAME/
ssh $REMOTE_USER@$REMOTE_HOST -t "\
    . /etc/profile; \
	cd $REMOTE_DIR/$PROJECT_NAME; \
	bash ./script/docker_run.sh;\
	true \
"

