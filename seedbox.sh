#!/bin/sh

TORRENT_DIR="/mnt/Torrents"
USENET_DIR="/mnt/Usenet"
CONFIG_DIR="/mnt/DockerData/"
TV_DIR="/mnt/TV"
MOVIES_DIR="/mnt/Movies"

DNS_SERVER="8.8.8.8"

RUTORRENT_PORT="8787"
RUTORRENT_SCGI_PORT="5000"
JACKETT_PORT="9117"
SICKRAGE_PORT="8989"
COUCHPOTATO_PORT="5050"
PLEX_PORT="32400"
PLEX_DNLA_PORT="32469"
PLEX_DLNA_UDP_PORT="1900"
PLEX_HOME_THEATER_PORT="3005"
PLEX_GDM_UDP_PORTS="32410-32414"
PLEX_REQUESTS_PORT="3000"
SABNZBD_HTTP_PORT="9797"
SABNSBD_HTTPS_PORT="9898"

docker rm -f plex
docker rm -f rtorrent
docker rm -f jackett
docker rm -f sickrage
docker rm -f couchpotato
docker rm -f plexrequests
docker rm -f sabnsbd

docker run \
  -td \
  --restart=always \
  --name=plex \
  --hostname=plex \
  --publish=${PLEX_PORT}:32400 \
  --publish=${PLEX_DNLA_PORT}:32469 \
  --publish=${PLEX_DLNA_UDP_PORT}:1900/udp \
  --publish=${PLEX_HOME_THEATER_PORT}:3005 \
  --publish=${PLEX_GDM_UDP_PORTS}:32410-32414/udp \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=${CONFIG_DIR}/plex:/config \
  --volume=${TV_DIR}:/media/tv \
  --volume=${MOVIES_DIR}:/media/movies \
  --dns=${DNS_SERVER} \
  -e PGID=1000 \
  -e PUID=1000 \
  -e VERSION=latest \
  linuxserver/plex

docker run \
  -tid \
  --restart=always \
  --name=rtorrent \
  --hostname=rtorrent \
  --publish=${RUTORRENT_PORT}:80 \
  --publish=${RUTORRENT_SCGI_PORT}:5000 \
  --publish=51101:51101/udp \
  --publish=51102:51102 \
  --dns=${DNS_SERVER} \
  --volume=${TORRENT_DIR}/incomplete:/incomplete \
  --volume=${TORRENT_DIR}/complete:/complete \
  --volume=${TORRENT_DIR}/watch:/watch \
  --volume=${TORRENT_DIR}/session:/session \
  --volume=${CONFIG_DIR}/rtorrent:/rtorrent \
  --volume=${CONFIG_DIR}/rutorrent:/rutorrent \
  zszafran/rtorrent-rutorrent:latest

docker run \
  -td \
  --restart=always \
  --name=sabnzbd \
  --hostname=sabnzbd \
  --publish=${SABNSBD_HTTP_PORT}:8080 \
  --publish=${SABNZBD_HTTPS_PORT}:9090 \
  --dns=${DNS_SERVER} \
  --volume=${CONFIG_DIR}/sabnzbd/:/config \
  --volume=${USENET_DIR}/complete:/downloads \
  --volume=${USENET_DIR}/incomplete:/incomplete-downloads \
  --volume=/etc/localtime:/etc/localtime:ro \
  -e PGID=1000 \
  -e PUID=1000 \
  linuxserver/sabnzbd

docker run \
  -td \
  --restart=always \
  --name=jackett \
  --hostname=jackett \
  --publish=${JACKETT_PORT}:9117 \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=${CONFIG_DIR}/jackett:/config \
  --volume=${TORRENT_DIR}/watch:/downloads \
  --dns=${DNS_SERVER} \
  -e PGID=1000 \
  -e PUID=1000 \
  linuxserver/jackett

docker run \
  -td \
  --restart=always \
  --name=sickrage \
  --hostname=sickrage \
  --publish=${SICKRAGE_PORT}:8081 \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=${CONFIG_DIR}/sickrage:/config \
  --volume=${TV_DIR}:/tv \
  --volume=${TORRENT_DIR}/complete:/complete \
  --link rtorrent:rtorrent \
  --link plex:plex \
  --dns=${DNS_SERVER} \
  -e PGID=1000 \
  -e PUID=1000 \
  linuxserver/sickrage

docker run \
  -td \
  --restart=always \
  --name=couchpotato \
  --hostname=couchpotato \
  --publish=${COUCHPOTATO_PORT}:5050 \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=${CONFIG_DIR}/couchpotato:/config \
  --volume=${TORRENT_DIR}/complete:/complete \
  --volume=${USENET_DIR}/complete:/usenet_complete \
  --volume=${MOVIES_DIR}:/movies \
  --link rtorrent:rtorrent \
  --link jackett:jackett \
  --link plex:plex \
  --link sabnzbd:sabnzbd \
  --dns=${DNS_SERVER} \
  -e PGID=1000 \
  -e PUID=1000 \
  linuxserver/couchpotato

docker run \
  -td \
  --restart=always \
  --name=plexrequests \
  --publish=${PLEX_REQUESTS_PORT}:3000 \
  --volume=/etc/localtime:/etc/localtime:ro \
  --volume=${CONFIG_DIR}/plexrequests:/config \
  --link couchpotato:couchpotato \
  --link sickrage:sickrage \
  --link plex:plex \
  --dns=${DNS_SERVER} \
  -e PGID=1000 \
  -e PUID=1000 \
  lsiodev/plexrequests
