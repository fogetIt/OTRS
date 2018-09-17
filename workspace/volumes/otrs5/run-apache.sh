#!/bin/bash
set -e
info_log ()
{
    echo -e "\033[32m=====> INFO: ${1}\033[0m"
}
info_log "Starting apache2..."
cp /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/otrs.conf
ln -sf /etc/apache2/sites-available/otrs.conf /etc/apache2/sites-enabled/otrs.conf
/opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=${OTRS_USER} --web-group=www-data
echo "RedirectMatch ^/$ /otrs-web/" >> /etc/apache2/sites-enabled/otrs.conf
echo "PerlPassEnv OTRS_DB_HOST" >> /etc/apache2/sites-enabled/otrs.conf
echo "PerlPassEnv OTRS_DB_PORT" >> /etc/apache2/sites-enabled/otrs.conf
echo "PerlPassEnv MYSQL_USER" >> /etc/apache2/sites-enabled/otrs.conf
echo "PerlPassEnv MYSQL_DATABASE" >> /etc/apache2/sites-enabled/otrs.conf
echo "PerlPassEnv MYSQL_PASSWORD" >> /etc/apache2/sites-enabled/otrs.conf
a2ensite otrs
a2enmod perl
a2enmod filter
a2enmod deflate
a2enmod headers
a2enmod rewrite
apachectl -M | sort | grep version
service apache2 stop
source /etc/apache2/envvars
export APACHE_RUN_USER=${OTRS_USER}
/usr/sbin/apache2 -DFOREGROUND