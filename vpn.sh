CONFIG_DIR="/mnt/DockerData/"

docker rm -f openvpn

docker run \
  -td \
  --restart=always \
  --name=openvpn \
  --volume=${CONFIG_DIR}/openvpn:/config \
  --net=host \
  --privileged \
  -e PGID=1000 \
  -e PUID=1000 \
  -e TZ="america/new_york" \
  -e INTERFACE="enp6s0" \
  linuxserver/openvpn-as
