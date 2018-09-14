FROM ubuntu:16.04
ARG OTRS_USER=otrs
ARG OTRS_GROUP=otrs
RUN apt-get update && mkdir /opt/otrs
COPY otrs /opt/otrs
RUN apt-get -y install \
        libfindbin-libs-perl \
        libapache-dbi-perl \
        liblwp-useragent-chicaching-perl \
        liblwp-useragent-determined-perl \
        liblwp-useragent-progressbar-perl
RUN apt-get -y install \
        $(perl /opt/otrs/bin/otrs.CheckModules.pl | grep 'Not installed!' | grep 'Use:' | awk '{print $8}' | cut -d "'" -f 1) && \
    perl /opt/otrs/bin/otrs.CheckModules.pl
COPY Config.pm /opt/otrs/Kernel/Config.pm
RUN perl -cw /opt/otrs/bin/otrs.Console.pl && \
    perl -cw /opt/otrs/bin/cgi-bin/index.pl && \
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl
RUN useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER} && \
    usermod -G www-data ${OTRS_GROUP} && \
    /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=${OTRS_USER} --web-group=${OTRS_GROUP}
# RUN apt-get install -y supervisor python-pip && pip install supervisor-stdout
RUN apt-get install -y apache2 libapache2-mod-perl2 mariadb-client && \
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf && \
    a2enmod perl && a2enmod filter && a2enmod deflate && a2enmod headers
EXPOSE 80