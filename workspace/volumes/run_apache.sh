#!/bin/bash
set -e
info_log ()
{
    echo -e "\033[32m=====> INFO: ${1}\033[0m"
}
info_log "Starting apache2..."
/opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=${OTRS_USER} --web-group=www-data
# ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
ln -sf /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs.conf
a2ensite otrs
a2enmod perl
a2enmod filter
a2enmod deflate
a2enmod headers
service apache2 restart
apachectl -M | sort | grep version