#!/bin/sh

unset HISTFILE

if test -z '{{mysql_user_pass}}'
then
    pass_arg=""
else
    pass_arg="-p'{{mysql_user_pass}}'"
fi

printf -- '----------\\nSHOW VARIABLES LIKE %%Path%%\\n----------\\n'
mysql -h127.0.0.1 -u{{mysql_user}} $pass_arg -e 'SHOW VARIABLES LIKE "%Path%"'

printf -- '----------\\nSHOW VARIABLES LIKE %%dir%%\\n----------\\n'
mysql -h127.0.0.1 -u{{mysql_user}} $pass_arg -e 'SHOW VARIABLES LIKE "%dir%"'

# Windows only
if test ! -z "$(uname -s|grep CYGWIN)"
then
    printf -- '----------\\n Using powershell to show MySQL service startup parameters\\n----------\\n'
    powershell -NoProfile -ExecutionPolicy bypass -command 'Get-WmiObject -Class Win32_Service -Filter "name = ""MySQL"""|fl *'
fi

printf -- '----------\\nSELECT LPAD(VARIABLE_NAME,50," ") ,VARIABLE_VALUE from INFORMATION_SCHEMA.global_variables\\n----------\\n'
mysql -h127.0.0.1 -u{{mysql_user}} $pass_arg -e \
'\
SELECT \
LPAD(VARIABLE_NAME,70," ") \
,VARIABLE_VALUE \
from INFORMATION_SCHEMA.global_variables\
';
