#!/bin/bash

CONFIG_DIR="/mnt/DockerData/"
DNS_SERVER="8.8.8.8"
MUXIMUX_PORT=80
GLANCES_PORT=61208
#SHOUT_PORT=9000
LOUNGE_PORT=9000

docker rm -f muximux
docker rm -f glances
docker rm -f shout
docker rm -f lounge

docker run \
  -td \
  --restart=always \
  --name=muximux \
  --hostname=muximux \
  --publish=${MUXIMUX_PORT}:80 \
  --dns=${DNS_SERVER} \
  --volume=${CONFIG_DIR}/muximux:/config \
  -e PGID=1000 \
  -e PUID=1000 \
  -e TZ="America/New_York" \
  linuxserver/muximux

docker run \
  -dti \
  --restart=always \
  --name=glances \
  --hostname=glances \
  --publish=${GLANCES_PORT}:61208 \
  --dns=${DNS_SERVER} \
  --volume=${ONFIG_DIR}/glances:/glances/conf \
  --volume=/var/run/docker.sock:/var/run/docker.sock:ro \
  --pid=host \
  -e GLANCES_OPT="-w" \
  docker.io/nicolargo/glances

#docker run \
#  -td \
#  --restart=always \
#  --name=shout \
#  --hostname=shout \
#  --publish=${SHOUT_PORT}:9000 \
#  --dns=${DNS_SERVER} \
#  --volume=/etc/localtime:/etc/localtime:ro \
#  --volume=${CONFIG_DIR}/shout:/config \
#  -e PGID=1000 \
#  -e PUID=1000 \
#  linuxserver/shout

docker run \
  -dt \
  --restart=always \
  --name=lounge \
  --hostname=lounge \
  --publish=${LOUNGE_PORT}:9000 \
  --dns=${DNS_SERVER} \
  --volume=${CONFIG_DIR}/lounge:/home/lounge/data \
  -e user=root \
  -e group=root \
  thelounge/lounge:latest
