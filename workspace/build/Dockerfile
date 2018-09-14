FROM ubuntu:16.04
ARG OTRS_USER=otrs
ARG OTRS_VERSION=6.0.10
RUN apt-get update && mkdir /opt/otrs
COPY "otrs${OTRS_VERSION}" /opt/otrs
RUN apt-get -y install \
        libfindbin-libs-perl \
        libapache-dbi-perl \
        liblwp-useragent-chicaching-perl \
        liblwp-useragent-determined-perl \
        liblwp-useragent-progressbar-perl
RUN apt-get -y install \
        $(perl /opt/otrs/bin/otrs.CheckModules.pl | grep 'Not installed!' | grep 'Use:' | awk '{print $8}' | cut -d "'" -f 1) && \
    perl /opt/otrs/bin/otrs.CheckModules.pl
RUN apt-get install -y cron mariadb-client apache2 libapache2-mod-perl2 supervisor
RUN useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER} && \
    usermod -G www-data ${OTRS_USER}
EXPOSE 80