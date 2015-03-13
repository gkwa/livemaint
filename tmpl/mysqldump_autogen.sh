#!/bin/sh

unset HISTFILE

cd /tmp

if test ! -z "$(env | grep WINDIR)"
then
    # windows

    if test ! -z $data_drive
    then
	cd $data_drive/
    fi
fi

database=streambox_live
exclude_list="activity streaming_log"

basename_streambox_live=mysql_dump_vN_$(date +%Y%m%d%H%M%S)_streambox_live
basename_mysql=mysql_dump_vN_$(date +%Y%m%d%H%M%S)_mysql
basename_zip=mysql_dump_vN_$(date +%Y%m%d%H%M%S)_streambox_live.sql

rm -f $basename_zip.zip
rm -f $basename_streambox_live.sql
rm -f $basename_mysql.sql

exclude_list_str=""


rm -f ${0}_tables_exclude.txt

for table in $exclude_list
do
    exclude_list_str="${exclude_list_str}^${table}$|"
    echo $table >>${0}_tables_exclude.txt
done

exclude_list_str="${exclude_list_str}^Tables_in_$database$"

mysql --host=127.0.0.1 \
    --user={{mysql_user}} --password='{{mysql_user_pass}}' \
    --execute="show tables from $database" >${0}_tables_all.txt

grep -vE "$exclude_list_str" ${0}_tables_all.txt >${0}_tables_will_dump.txt

tables=$(cat ${0}_tables_will_dump.txt|tr '\n' ' ')

##############################
# Get streambox_live schema version
##############################

# dump all tables except tables in $exclude_list to .sql file
mysql \
    --database=$database \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    $database -e 'SELECT * FROM slsconfig \
	WHERE name = "required_ver_ls_php" AND is_active = 1 ORDER BY dt_created DESC' >${0}_server_ver.txt

cat ${0}_server_ver.txt

# FIXME: This produces multiple version numbers which makes me pause:

# slsconfig_id	name	value	is_active	dt_update	dt_created
# 148	required_ver_ls_php	3.2	1	2015-03-13 04:05:27	2015-03-12 21:04:38
# 244	required_ver_ls_php	1.0	1	2015-03-13 04:04:37	2015-03-12 21:04:38
# -- Warning: Skipping the data of table mysql.event. Specify the --events option explicitly.

# 7-Zip [64] 9.20  Copyright (c) 1999-2010 Igor Pavlov  2010-11-18
# p7zip Version 9.20 (locale=C.UTF-8,Utf16=on,HugeFiles=on,2 CPUs)
# Scanning

# Creating archive mysql_dump_vN_20150313110613_streambox_live.sql.zip

# Compressing  mysql_dump_vN_20150313110613_mysql.sql
# Compressing  mysql_dump_vN_20150313110613_streambox_live.sql

# Everything is Ok
# 156K	mysql_dump_vN_20150313110613_streambox_live.sql.zip
# 96K	mysql_dump_vN_20150313110613_streambox_live.sql
# 568K	mysql_dump_vN_20150313110613_mysql.sql

##############################

# dump all tables except tables in $exclude_list to .sql file
mysqldump \
    --host=127.0.0.1 \
    --lock-all-tables --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    $database $tables >$basename_streambox_live.sql

# dump structure for table(s) in $exclude_list
mysqldump \
    --no-data \
    --host=127.0.0.1 \
    --lock-all-tables --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    $database $exclude_list >>$basename_streambox_live.sql

# dump the database mysql
mysqldump \
    --host=127.0.0.1 \
    --lock-all-tables --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    mysql >>$basename_mysql.sql

7z a -mx9 $basename_zip.zip $basename_streambox_live.sql $basename_mysql.sql
du -sh $basename_zip.zip $basename_streambox_live.sql $basename_mysql.sql

# rm -f $basename_zip.zip
rm -f $basename_streambox_live.sql
rm -f $basename_mysql.sql
rm -f ${0}_server_ver.txt