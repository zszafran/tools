docker rm -f influxdb
docker rm -f cadvisor
docker rm -f grafana

docker run \
  -d \
  --restart always \
  --name influxdb \
  --publish=8083:8083 \
  --publish=8086:8086 \
  --expose 8090 \
  --expose 8099 \
  --volume=/mnt/Torrents/.influxdb:/data \
  -e PRE_CREATE_DB=cadvisor \
  tutum/influxdb

docker run \
  --restart always \
  --name=cadvisor \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/mnt/Docker/:/mnt/Docker:ro \
  --publish=8888:8080 \
  --detach=true \
  --link influxdb:influxdb \
  google/cadvisor:latest \
  -storage_driver=influxdb \
  -storage_driver_db=cadvisor \
  -storage_driver_host=jailbot:8086 \
  -storage_driver_user=root \
  -storage_driver_password=root

docker run \
  -d \
  --restart always \
  --name grafana \
  --publish=3000:3000 \
  -e INFLUXDB_HOST=jailbot \
  -e INFLUXDB_PORT=8086 \
  -e INFLUXDB_NAME=cadvisor \
  -e INFLUXDB_USER=root \
  -e INFLUXDB_PASS=root \
  --link influxdb:influxdb \
  --volume=/mnt/Torrents/.grafana/lib:/var/lib/grafana \
  --volume=/mnt/Torrents/.grafana/plugins:/var/lib/grafana/plugins \
  --volume=/mnt/Torrents/.grafana/logs:/var/log/grafana \
  --volume=/mnt/Torrents/.grafana/etc:/etc/grafana \
  grafana/grafana
