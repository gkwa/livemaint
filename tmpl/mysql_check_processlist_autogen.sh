#!/bin/sh

unset HISTFILE

cd /tmp
cat << __EOT__ >{{scrBase}}.sql

-- http://stackoverflow.com/questions/7432241/mysql-show-status-active-or-total-connections

-- STATUS;
SHOW FULL PROCESSLIST;
-- SHOW GLOBAL STATUS;

__EOT__

mysql --table -h127.0.0.1 -u{{mysql_user}} -p'{{mysql_user_pass}}' <{{scrBase}}.sql 2>/dev/null
rm -f {{scrBase}}.sql
