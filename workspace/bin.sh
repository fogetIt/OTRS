#!/bin/bash
set -e
export OTRS_USER=otrs
export OTRS_GROUP=otrs
export OTRS_VERSION=6.0.10
pushd build
    if [[ ! -d otrs ]]; then
        mkdir otrs
        curl http://ftp.otrs.org/pub/otrs/otrs-${OTRS_VERSION}.tar.gz | tar -zxvf - -C otrs --strip-components 1
    fi
    docker build \
        --build-arg OTRS_USER=${OTRS_USER} \
        --build-arg OTRS_GROUP=${OTRS_GROUP} \
        --build-arg OTRS_VERSION=${OTRS_VERSION} \
        -t otrs:${OTRS_VERSION} .
popd
docker-compose down
docker-compose rm -f -v
echo 'y' | docker volume prune
docker pull juanluisbaptiste/otrs-mariadb:latest
docker-compose up -d
docker logs otrs --follow
# localhost:8080/otrs/installer.pl