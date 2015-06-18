#!/bin/sh

unset HISTFILE

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp
cat << __EOT__ >{{scrBase}}.sql
use {{database}};

SELECT '----------------------------------------------' AS '';


-- http://blog.webyog.com/2012/11/20/how-to-monitor-mysql-replication
-- check slave status

SHOW GLOBAL STATUS like 'slave_running';

SELECT 'SHOW MASTER STATUS' AS '';
SHOW MASTER STATUS;

SELECT 'SHOW SLAVE STATUS;' AS '';
SHOW SLAVE STATUS;


-- http://stackoverflow.com/a/4225613;
SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES where TABLE_SCHEMA = 'streambox_live';

__EOT__

mysql \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>/dev/null |
    grep -v 'Variable_name'
