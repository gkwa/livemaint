#!/bin/sh

unset HISTFILE

set -e
set -u

trap "rm -f {{scrBase}}_mysql_init.sh {{scrBase}}.sql {{scrBase}}_mysql_init100.sql {{scrBase}}_mysql_init110.sql {{scrBase}}_mysql_init.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp

# ssh $host "cd /c/sls_db/sb_backup && 7z x -y $zip"



zip=mysql_dump_vN_20150512_streambox_live_1431482703.sql.zip

sqlfile_streambox_live=$(echo $zip| sed -e 's,\.zip,,')
sqlfile_mysql=$(echo $sqlfile_streambox_live| sed -e 's,streambox_live,mysql,')

if test ! -f /c/sls_db/sb_backup/$sqlfile_streambox_live
then
    pushd /c/sls_db/sb_backup
    echo unzipping $zip
    7z x -y $zip
    popd
fi

# reset root password:
# https://dev.mysql.com/doc/refman/5.6/en/resetting-permissions.html

set +e
net stop mysql
taskkill /F /IM mysqld.exe 2>/dev/null
taskkill /F /IM mysqld.exe 2>/dev/null
set -e

cat <<'__EOT__' >{{scrBase}}_mysql_init.sql
UPDATE mysql.user SET Password=PASSWORD('{{mysql_user_pass}}') WHERE User='root';
FLUSH PRIVILEGES;
__EOT__

minit={{scrBase}}_mysql_init.sql

cat <<'__EOT__' >{{scrBase}}_mysql_init.sh
#!/bin/sh

# Use absolute path incase c:\MySQL\bin isn't yet in system path.
# c:\MySQL\bin would be in system path after reboot after install.
/c/MySQL/bin/mysqld.exe \
    --defaults-file=c:/mysql/my.ini \
    --skip-grant-table
__EOT__

sh -x {{scrBase}}_mysql_init.sh &
sleep 5

mysql -uroot -h127.0.0.1 <{{scrBase}}_mysql_init.sql

set +e
taskkill /F /IM mysqld.exe 2>/dev/null
taskkill /F /IM mysqld.exe 2>/dev/null
set -e

net start mysql

sqlfile_abspath=$(cygpath --mixed /c/sls_db/sb_backup/$sqlfile_streambox_live)

sed -i.bak -e 's,^mysql.default_password.*=.*,mysql.default_password = {{mysql_sls_php_pass}},' /c/php/php.ini
net stop apache2.4
net start apache2.4

cat <<__EOT__ >{{scrBase}}_mysql_init100.sql
show databases;
drop database if exists streambox_live;
create database if not exists streambox_live;
use streambox_live;
source $sqlfile_abspath;

-- send comment to stdout
select 'Importing $sqlfile_abspath complete' as '';
__EOT__

echo importing $sqlfile_abspath...
mysql -h127.0.0.1 -uroot -p'{{mysql_user_pass}}' <{{scrBase}}_mysql_init100.sql

sqlfile_abspath=$(cygpath --mixed /c/sls_db/sb_backup/$sqlfile_mysql)

cat <<__EOT__ >{{scrBase}}_mysql_init110.sql
use mysql;

-- send comment to stdout
select 'Importing $sqlfile_abspath complete' as '';
source $sqlfile_abspath;
__EOT__

echo importing $sqlfile_abspath...
mysql -uroot -h127.0.0.1 -Dmysql --password='{{mysql_user_pass}}' <{{scrBase}}_mysql_init110.sql
