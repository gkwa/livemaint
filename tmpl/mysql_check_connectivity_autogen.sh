#!/bin/sh

unset HISTFILE

mysql -u{{mysql_user}} -p{{mysql_use_pass}} \
    -D{{database}} -e '{{sql_command}}'
