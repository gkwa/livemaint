#!/bin/sh

unset HISTFILE

cd /tmp

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cat << __EOT__ >{{scrBase}}.sql

-- http://stackoverflow.com/a/9620273

SELECT "{{server}}" as Server,
table_name AS "Tables",
round(((data_length + index_length) / 1024 / 1024), 2) "Size in MB",
DATE_FORMAT(NOW(),'%m-%d-%Y') AS Date
FROM information_schema.TABLES
WHERE table_schema = "{{mysql_database}}"
ORDER BY (data_length + index_length) DESC;
__EOT__

mysql \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql
