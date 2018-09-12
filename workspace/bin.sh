#!/bin/bash
set -e
docker-compose down
docker-compose rm -f -v
echo 'y' | docker volume prune
docker-compose pull
docker-compose up -d
docker logs otrs --follow
# localhost:8080/otrs/installer.pl