#!/bin/bash
set -xe
cd ${0%/*}/..
source .env
# set default password if not exists
[ ! -f data/secret/htpasswd ] && echo 'admin:$apr1$.6mu9N8n$xOuGesr4JZZkdiZo/j318.' > data/secret/htpasswd
[ ! -f data/secret/vncpasswd ] && echo 'admin -> admin:admin' > data/secret/vncpasswd
[ ! -f data/secret/ipmipasswd ] && echo 'admin:admin -> admin:admin' > data/secret/ipmipasswd
[ ! -f data/secret/totp.secret ] && touch data/secret/totp.secret
# docker-compose build --pull
docker-compose pull
docker-compose rm -f -s || true
export DEVICE_GROUP_ID=$(id -g ${DEVICE_GROUP:-videodriver})
[ -c /dev/kvmd/kvmd-video ] && export CAP_MAJOR=$(printf "%d" 0x$(stat -c %t /dev/kvmd/kvmd-video))
[ -c /dev/kvmd/kvmd-hid ] && export HID_MAJOR=$(printf "%d" 0x$(stat -c %t /dev/kvmd/kvmd-hid))
[ -c /dev/dri/renderD128 ] && export VAAPI_MAJOR=$(printf "%d" 0x$(stat -c %t /dev/dri/renderD128))

docker-compose up -d --remove-orphan --no-build
sleep 2
docker-compose logs -f 