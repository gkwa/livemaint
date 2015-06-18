#!/bin/sh

unset HISTFILE

cd /tmp

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

mysql \
    --table \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 | \
    grep -vi 'Warning: Using a password on the command line interface can be insecure.'
