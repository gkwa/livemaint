#!/bin/sh
unset HISTFILE

cd /tmp

sqlfile_remove_user=$0.remove.sql

trap "rm -f $sqlfile_remove_user; exit" SIGHUP SIGINT SIGQUIT SIGTERM EXIT

##############################
# Create SQL script to remove tempoary user
##############################

cat <<'__EOT__' >$sqlfile_remove_user
grant usage on *.* to '{{dba_username}}'@'localhost';
drop user '{{dba_username}}'@'localhost';

grant usage on *.* to '{{dba_username}}'@'%';
drop user '{{dba_username}}'@'%';

flush privileges;
__EOT__
chmod 700 $sqlfile_remove_user

mysql \
    --table \
    --host=127.0.0.1 \
    --database=mysql \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <$sqlfile_remove_user
