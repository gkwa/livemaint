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

seconds_since_epoch=$(date +%s)

basename_streambox_live=mysql_dump_vN_$(date +%Y%m%d)_streambox_live_$seconds_since_epoch
basename_mysql=mysql_dump_vN_$(date +%Y%m%d)_mysql_$seconds_since_epoch
basename_zip=mysql_dump_vN_$(date +%Y%m%d)_streambox_live_$seconds_since_epoch.sql

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

# dump all tables except tables in $exclude_list to .sql file
mysqldump \
    --host=127.0.0.1 \
    --single-transaction --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    $database $tables >$basename_streambox_live.sql

# dump structure for table(s) in $exclude_list
mysqldump \
    --no-data \
    --host=127.0.0.1 \
    --single-transaction --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    $database $exclude_list >>$basename_streambox_live.sql

# dump the database mysql
mysqldump \
    --host=127.0.0.1 \
    --single-transaction --compress --quick \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    mysql >>$basename_mysql.sql

7z a -mx9 $basename_zip.zip $basename_streambox_live.sql $basename_mysql.sql
du -sh $basename_zip.zip $basename_streambox_live.sql $basename_mysql.sql

# rm -f $basename_zip.zip
rm -f $basename_streambox_live.sql
rm -f $basename_mysql.sql
