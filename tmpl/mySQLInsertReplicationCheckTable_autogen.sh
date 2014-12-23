#!/bin/sh

unset HISTFILE

cd /tmp
cat << '__EOT__' >{{scrBase}}.sql

SELECT
    count(*)
FROM
    streambox_live.replication_check;

SELECT
    *
FROM
    streambox_live.replication_check;
__EOT__

mysql --table -h127.0.0.1 -Dstreambox_live --user={{mysql_user}} --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>/dev/null
rm -f {{scrBase}}.sql
