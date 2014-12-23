#!/bin/sh

unset HISTFILE

mysql --user={{mysql_user}} --password='{{mysql_use_pass}}' \
    -D{{database}} -e '{{sql_command}}'
