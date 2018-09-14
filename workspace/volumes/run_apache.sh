#!/bin/bash
set -e
info_log "Starting apache2..."
useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER}
usermod -G www-data ${OTRS_USER}
/opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=${OTRS_USER} --web-group=www-data
# ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs.conf
a2ensite otrs
a2enmod perl
a2enmod filter
a2enmod deflate
a2enmod headers
service apache2 restart
apachectl -M | sort | grep version