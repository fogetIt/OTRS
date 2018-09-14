#!/bin/bash
set -e
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
/etc/init.d/apache2 start
service cron start
apachectl -M | sort
# supervisord&
pushd /opt/otrs
    echo "Starting OTRS daemon..."
    su -c 'bin/otrs.Daemon.pl start' -s /bin/bash ${OTRS_USER}
    # su -c 'bin/Cron.sh start' -s /bin/bash ${OTRS_USER}
    echo "OTRS Ready !"
popd

trap 'kill ${!}; term_handler' SIGTERM
while true
do
    tail -f /dev/null & wait ${!}
done