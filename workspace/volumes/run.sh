#!/bin/bash
set -e
info_log ()
{
    echo -e "\033[32m=====> INFO: ${1}\033[0m"
}
MYSQLCMD="mysql -h ${OTRS_DB_HOST} -P ${OTRS_DB_PORT} -u root -p${MYSQL_ROOT_PASSWORD} "
while ! ${MYSQLCMD} -e "SHOW DATABASES;"
do
    sleep 5
done
if [[ ${OTRS_DB_INIT} == 'true' ]]; then
    ${MYSQLCMD} -e "CREATE DATABASE ${OTRS_DB_NAME} CHARACTER SET utf8;"
    ${MYSQLCMD} -e "GRANT ALL PRIVILEGES ON ${OTRS_DB_NAME}.* TO '${OTRS_DB_USER}'@'%' IDENTIFIED BY '${OTRS_DB_PASSWORD}';"
    ${MYSQLCMD} -e 'FLUSH PRIVILEGES;'
    ${MYSQLCMD} otrs < /opt/otrs/scripts/database/otrs-schema.mysql.sql
    ${MYSQLCMD} otrs < /opt/otrs/scripts/database/otrs-initial_insert.mysql.sql
    ${MYSQLCMD} otrs < /opt/otrs/scripts/database/otrs-schema-post.mysql.sql
fi
set -x
info_log "Checking OTRS..."
    perl -cw /opt/otrs/bin/otrs.Console.pl
    perl -cw /opt/otrs/bin/cgi-bin/index.pl
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl
info_log "Starting apache2..."
    useradd -d /opt/otrs -c 'OTRS user' ${OTRS_USER}
    usermod -G www-data ${OTRS_GROUP}
    /opt/otrs/bin/otrs.SetPermissions.pl /opt/otrs --otrs-user=${OTRS_USER} --web-group=www-data
    a2ensite otrs
    a2enmod perl
    a2enmod filter
    a2enmod deflate
    a2enmod headers
    ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/apache2/sites-enabled/otrs.conf
    /etc/init.d/apache2 restart
    apachectl -M | sort
service cron restart
# supervisord&
pushd /opt/otrs
    info_log "Starting OTRS daemon..."
    su -c 'bin/otrs.Daemon.pl start' -s /bin/bash ${OTRS_USER}
    # su -c 'bin/Cron.sh start' -s /bin/bash ${OTRS_USER}
popd
info_log "OTRS Ready !"

trap 'kill ${!}; term_handler' SIGTERM
while true
do
    tail -f /dev/null & wait ${!}
done