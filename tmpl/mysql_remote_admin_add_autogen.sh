#!/bin/sh
unset HISTFILE

cd /tmp

sqlfile_add_user=$0.add.sql

trap "rm -f $sqlfile_add_user; exit" SIGHUP SIGINT SIGQUIT SIGTERM EXIT

##############################
# Create SQL script to add mysql dba
##############################

cat <<'__EOT__' >$sqlfile_add_user
# There is no drop user if user exists in MySQL SQL so hee's workaround:
grant usage on *.* to '{{dba_username}}'@'localhost';
drop user '{{dba_username}}'@'localhost';
grant usage on *.* to '{{dba_username}}'@'%';
drop user '{{dba_username}}'@'%';

# Starting fresh now:

# Localhost
create user '{{dba_username}}'@'localhost' IDENTIFIED BY '{{dba_password}}';
grant all privileges on *.* to '{{dba_username}}'@'localhost' with grant option;

# Everywhere
create user '{{dba_username}}'@'%' identified by '{{dba_password}}';
grant all privileges on *.* to '{{dba_username}}'@'%' with grant option;

flush privileges;
__EOT__
chmod 700 $sqlfile_add_user

mysql \
    --table \
    --host=127.0.0.1 \
    --database=mysql \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <$sqlfile_add_user
