#!/bin/bash -e

docker build -t bethrezen/docker-php72 ./
docker push bethrezen/docker-php72