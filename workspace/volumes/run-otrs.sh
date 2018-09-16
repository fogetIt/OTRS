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
    if [[ ${OTRS_DB_CONTAINER} != 'true' ]]; then
        sed -i s/{{MYSQL_USER}}/${MYSQL_USER}/g init-db.sql
        sed -i s/{{MYSQL_PASSWORD}}/${MYSQL_PASSWORD}/g init-db.sql
        sed -i s/{{MYSQL_DATABASE}}/${MYSQL_DATABASE}/g init-db.sql
        ${MYSQLCMD} ${MYSQL_DATABASE} < init-db.sql
    fi
    ${MYSQLCMD} ${MYSQL_DATABASE} < /opt/otrs/scripts/database/otrs-schema.mysql.sql
    ${MYSQLCMD} ${MYSQL_DATABASE} < /opt/otrs/scripts/database/otrs-initial_insert.mysql.sql
    ${MYSQLCMD} ${MYSQL_DATABASE} < /opt/otrs/scripts/database/otrs-schema-post.mysql.sql
fi
info_log "Configure OTRS..."
(
    cp /opt/otrs/Kernel/Config.pm.dist /opt/otrs/Kernel/Config.pm
    # sed -n '/\($Self->{DatabaseHost} = \).\+;$/p' /opt/otrs/Kernel/Config.pm.dist
    sed -i 's/\($Self->{Database} = \).\+;$/\1$ENV{'MYSQL_DATABASE'};/g' /opt/otrs/Kernel/Config.pm
    sed -i 's/\($Self->{DatabasePw} = \).\+;$/\1$ENV{'MYSQL_PASSWORD'};/g' /opt/otrs/Kernel/Config.pm
    sed -i 's/\($Self->{DatabaseHost} = \).\+;$/\1$ENV{'OTRS_DB_HOST'};/g' /opt/otrs/Kernel/Config.pm
    sed -i 's/\($Self->{DatabaseUser} = \).\+;$/\1$ENV{'MYSQL_USER'};/g' /opt/otrs/Kernel/Config.pm
    sed -i 's/#use DBD::mysql ();$/use DBD::mysql ();/g' /opt/otrs/scripts/apache2-perl-startup.pl
    sed -i 's/#use Kernel::System::DB::mysql;$/use Kernel::System::DB::mysql;/g' /opt/otrs/scripts/apache2-perl-startup.pl
)
info_log "Checking OTRS..."
(
    perl -cw /opt/otrs/bin/otrs.Console.pl
    perl -cw /opt/otrs/bin/cgi-bin/index.pl
    perl -cw /opt/otrs/bin/cgi-bin/customer.pl
)
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