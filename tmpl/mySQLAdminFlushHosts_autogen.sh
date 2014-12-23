#!/bin/sh

unset HISTFILE

# http://dev.mysql.com/doc/refman/5.0/en/blocked-host.html

mysqladmin --user={{mysql_user}} --password='{{mysql_user_pass}}' flush-hosts 2>&1 |
grep -v 'Warning: Using a password on the command line interface can be insecure.'
