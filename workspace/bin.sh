#!/bin/bash
set -e
export OTRS_USER=otrs
export OTRS_VERSION=5.0.16
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
docker-compose rm -f -v
echo 'y' | docker volume prune
docker pull juanluisbaptiste/otrs-mariadb:latest
docker-compose up -d
docker logs otrs --follow
# otrs/installer.pl