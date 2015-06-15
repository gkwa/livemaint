#!/bin/sh

unset HISTFILE

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp
cat << __EOT__ >{{scrBase}}.sql
use {{database}};
show variables like "character_set_database";
show variables like "collation_database";

__EOT__

mysql \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>/dev/null |
    grep -v 'Variable_name'
