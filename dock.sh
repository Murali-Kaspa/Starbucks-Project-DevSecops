#!/bin/bash

read -rp "Enter the container ID you want to keep safe: " container_id

docker ps -aq | grep -v "$container_id" | xargs -r docker stop
docker ps -aq | grep -v "$container_id" | xargs -r docker rm -f
docker image prune -a -f

