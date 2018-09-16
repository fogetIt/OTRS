#!/bin/bash
set -e
export OTRS_USER=otrs
export OTRS_VERSION=5.0.16
# export OTRS_VERSION=5.0.22
# export OTRS_VERSION=6.0.5
# export OTRS_VERSION=6.0.9
# export OTRS_VERSION=6.0.10
docker-compose down
pushd build
    if [[ ! -d "otrs${OTRS_VERSION}" ]]; then
        mkdir "otrs${OTRS_VERSION}"
        curl http://ftp.otrs.org/pub/otrs/otrs-${OTRS_VERSION}.tar.gz | tar -zxvf - -C "otrs${OTRS_VERSION}" --strip-components 1
    fi
popd
if [[ -z $(docker images otrs:${OTRS_VERSION} -q) ]]; then
    docker-compose build
fi
if [[ -z $(docker images mariadb:latest -q) ]]; then
    docker pull mariadb:10.3.9
    docker tag mariadb:10.3.9 mariadb:latest
fi
docker-compose rm -f -v
echo 'y' | docker volume prune
docker-compose up -d
docker logs otrs --follow
# otrs/installer.pl