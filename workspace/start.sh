#!/bin/bash
set -e
export OTRS_USER=otrs
export OTRS_VERSION=${1}
docker-compose down
if [ ${OTRS_VERSION%%.*} == '5' ]; then
    # otrs-5.0.16/5.0.22/5.0.26
    pushd build
        if [[ ! -d "otrs-${OTRS_VERSION}" ]]; then
            mkdir "otrs-${OTRS_VERSION}"
            curl http://ftp.otrs.org/pub/otrs/otrs-${OTRS_VERSION}.tar.gz | tar -zxvf - -C "otrs-${OTRS_VERSION}" --strip-components 1
        fi
    popd
    export NUM=${OTRS_VERSION%%.*}
    if [[ -z $(docker images otrs:${OTRS_VERSION} -q) ]]; then
        docker-compose build
    fi
else
    exit 1
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