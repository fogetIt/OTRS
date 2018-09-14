#!/bin/bash
set -e
export OTRS_USER=otrs
export OTRS_GROUP=otrs
export OTRS_VERSION=6.0.10
if [[ -z $(docker images otrs:${OTRS_VERSION} -q) ]]; then
    docker-compose build
fi
pushd build
    if [[ ! -d otrs ]]; then
        mkdir otrs
        curl http://ftp.otrs.org/pub/otrs/otrs-${OTRS_VERSION}.tar.gz | tar -zxvf - -C otrs --strip-components 1
    fi
popd
docker-compose down
docker-compose rm -f -v
echo 'y' | docker volume prune
docker pull juanluisbaptiste/otrs-mariadb:latest
docker-compose up -d
docker logs otrs --follow
# otrs/installer.pl