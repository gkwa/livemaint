#!/bin/sh

unset HISTFILE

cd /tmp

##############################
# find data partition to downlaod zip file to
##############################

freePartition=''

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
# mysql import
##############################

cd $freePartition

basename=streambox_live_mysqldump_2014-10-15-22-13-1413425598
zip=$basename.zip
sql=$basename.sql
wget --timestamping -nv http://taylors-bucket.s3.amazonaws.com/$zip
if [ ! -f $sql ]
then
    unzip -j -P Stre@mb0x -o -d $basename $zip
fi

if test -z "$(env | grep WINDIR)"
then

    # Linux
    sudo mysql -h127.0.0.1 -u{{mysql_user}} -p'{{mysql_user_pass}}' -e "DROP DATABASE IF EXISTS {{database}}"
    sudo rm -rf '/var/lib/mysql/{{database}}/' #workaround: http://stackoverflow.com/questions/12196996/mysql-error-dropping-database-errno-13-errno-17-errno-39
    sudo mysqladmin -h127.0.0.1 -u{{mysql_user}} -p{{mysql_user_pass}} create {{database}}

    cd $freePartition/$basename
    for sqlfile in `ls *.sql`
    do
	sqlbn=$(echo $sqlfile|sed -e 's,\.sql$,,') # from ifb.sql return just ifb
	sudo mysql \
	    -h127.0.0.1 \
	    -u{{mysql_user}} \
	    -p'{{mysql_user_pass}}' \
	    {{database}} <$sqlfile
    done

else

    # Windows
    mysql -h127.0.0.1 -u{{mysql_user}} -p'{{mysql_user_pass}}' -e "DROP DATABASE IF EXISTS {{database}}"
    mysqladmin -h127.0.0.1 -u{{mysql_user}} -p'{{mysql_user_pass}}' create {{database}}

    cd $freePartition/$basename
    for sqlfile in `ls *.sql`
    do
	sqlbn=$(echo $sqlfile|sed -e 's,\.sql$,,') # from ifb.sql return just ifb
	mysql \
	    -h127.0.0.1 \
	    -u{{mysql_user}} \
	    -p'{{mysql_user_pass}}' \
	    {{database}} <$sqlfile
    done
fi
