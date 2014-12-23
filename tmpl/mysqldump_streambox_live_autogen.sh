#!/bin/sh

unset HISTFILE

cd /tmp

date=$(date +%Y-%m-%d-%H-%M-%s)
dumpDirBaseName={{database}}_mysqldump_${date}
zipFile="$dumpDirBaseName.zip"

freePartition=''

##############################
# find data partition to downlaod zip file to
##############################

# Try to backup to non OS partition since our drives are small
if test -z "$(env | grep WINDIR)"
then
    # Linux
    freePartition=/tmp
else

    # Windows
    for drive in e d c
    do
	if test -d /$drive
	then
	    freePartition="/$drive"
	    break
	fi
    done
fi

##############################
# mysqldump excluding tables we dont want
##############################

dumpBaseDir=$freePartition/$dumpDirBaseName
zipFileAbsPath=$freePartition/$zipFile

mkdir -p $dumpBaseDir

DBTODUMP={{database}}
SQL="SET group_concat_max_len = 10240;"
SQL="${SQL} SELECT GROUP_CONCAT(table_name separator ' ')"
SQL="${SQL} FROM information_schema.tables WHERE table_schema='${DBTODUMP}'"
# SQL="${SQL} AND table_name NOT IN ('t1','t2')"

# skip activity table because its too big ~1.5GB
SQL="${SQL} AND table_name NOT IN ('activity','streaming_log')"
TBLIST=`mysql -h127.0.0.1 --user={{mysql_user}} --password='{{mysql_user_pass}}' -AN -e"${SQL}"`


for table in $TBLIST
do
    dumpFileAbsPath=$dumpBaseDir/$table.sql
    mysqldump -h127.0.0.1 \
	--user={{mysql_user}} \
	--password='{{mysql_user_pass}}' \
	${DBTODUMP} $table >$dumpFileAbsPath
    du -sh $dumpFileAbsPath
#    zip -9r $zipFileAbsPath $dumpFileAbsPath
#    du -sh $zipFileAbsPath
done

zip -9r --password Stre@mb0x $zipFileAbsPath $dumpBaseDir
