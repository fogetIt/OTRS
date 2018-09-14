FROM ubuntu:16.04
ARG OTRS_USER=otrs
ARG OTRS_GROUP=otrs
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
RUN cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm && \
    perl -cw /opt/otrs/bin/otrs.Console.pl && \
    perl -cw /opt/otrs/bin/cgi-bin/index.pl && \
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl
RUN useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER} && usermod -G www-data ${OTRS_GROUP}
# RUN apt-get install -y supervisor python-pip && pip install supervisor-stdout
RUN apt-get install -y apache2 libapache2-mod-perl2 && \
    a2enmod perl && a2enmod filter && a2enmod deflate && a2enmod headers && \
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
RUN apt-get install -y mariadb-client cron
EXPOSE 80