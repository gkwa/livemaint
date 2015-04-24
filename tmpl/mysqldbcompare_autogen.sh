#!/bin/sh

# mysqldbcompare is provided by mysql.utilties.  It was a bit silly to
# install that on 64bit windows:
#
# choco install vcredist2013 -yes -forcex86
# choco install vcredist2013 -yes -force
# choco install mysql.workbench -yes -forcex86
# choco install mysql.utilities -yes -forcex86

unset HISTFILE

PATH=/c/Program\ Files/MySQL/MySQL\ Utilities:$PATH
PATH=/c/Program\ Files\ \(x86\)/MySQL/MySQL\ Utilities:$PATH

# mysqldbcompare is crashing, try reducing path to exlcude cygwin
# http://is.gd/4mJi8O
PATH=/c/Program\ Files/MySQL/MySQL\ Utilities
PATH=/c/Program\ Files\ \(x86\)/MySQL/MySQL\ Utilities:$PATH

# --skip-checksum-table
# http://dev.mysql.com/doc/mysql-utilities/1.5/en/mysqldbcompare.html#option_mysqldbcompare_skip-checksum-table

mysqldbcompare --version

mysqldbcompare \
    --server1={{mysql_server1_user}}:{{mysql_server1_user_password}}@{{mysql_server1}} \
    --server2={{mysql_server2_user}}:{{mysql_server1_user_password}}@{{mysql_server2}}: \
    --changes-for=server1 \
    {{mysql_server1_dbname}}:{{mysql_server2_dbname}} \
    --difftype=sql \
    --run-all-tests \
    --skip-checksum-table
