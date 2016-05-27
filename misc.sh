docker rm -f pastebin

docker run \
  -d \
  --name pastebin \
  --publish 1987:1987 \
  mkodockx/docker-pastebin
