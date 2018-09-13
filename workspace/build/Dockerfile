FROM ubuntu:16.04
ARG OTRS_USER=otrs
ARG OTRS_GROUP=otrs
ARG OTRS_VERSION=6.0.10
RUN apt-get update && mkdir /opt/otrs
COPY otrs /opt/otrs
RUN apt-get install -y \
        libapache2-mod-perl2 \
        libdbd-mysql-perl \
        libtimedate-perl \
        libnet-dns-perl \
        libnet-ldap-perl \
        libio-socket-ssl-perl \
        libpdf-api2-perl \
        libdbd-mysql-perl \
        libsoap-lite-perl \
        libtext-csv-xs-perl \
        libjson-xs-perl \
        libapache-dbi-perl \
        libxml-libxml-perl \
        libxml-libxslt-perl \
        libyaml-perl \
        libarchive-zip-perl \
        libcrypt-eksblowfish-perl \
        libencode-hanextra-perl \
        libmail-imapclient-perl \
        libtemplate-perl && \
    cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm && \
    perl -cw /opt/otrs/bin/cgi-bin/index.pl && \
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl && \
    perl -cw /opt/otrs/bin/otrs.Console.pl
# RUN apt-get install -y python-pip && \
#     pip install supervisor-stdout
RUN apt-get install -y apache2 libapache2-mod-perl2 && \
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf && \
    a2enmod perl && \
    a2enmod filter && \
    a2enmod version && \
    a2enmod deflate && \
    a2enmod headers
RUN useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER} && \
    usermod -G www-data ${OTRS_GROUP} && \
    perl /opt/otrs/bin/otrs.SetPermissions.pl && \
    perl /opt/otrs/bin/otrs.CheckModules.pl
EXPOSE 80/tcp
CMD '/opt/otrs/bin/otrs.Daemon.pl start'