#!/bin/sh

: <<COMMENTBLOCK
master master replication
http://randymelder.com/2012/04/26/how-i-setup-mysql-multi-master-replication/
https://www.linode.com/docs/databases/mysql/mysql-master-master-replication
http://www.lefred.be/node/45

master master is not the same as multi-master.  Multi-master replication:
http://dev.mysql.com/doc/refman/5.6/en/mysql-cluster-replication-multi-master.html
COMMENTBLOCK

unset HISTFILE

set -e
set -u

trap "rm -f /tmp/myini.py otkqummaiujtea.sql yw0gf4bxxntqaw.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp

# install easy_install, then pip
pip --version || {

    wget https://bootstrap.pypa.io/ez_setup.py -O - | python
    easy_install pip
}

pip show netifaces >/dev/null || {
	set +u
	export C_INCLUDE_PATH=/usr/include/python2.7:$C_INCLUDE_PATH
	export CPLUS_INCLUDE_PATH=/usr/include/python2.7:$CPLUS_INCLUDE_PATH
	set -u
	pip install netifaces
}
pip show configobj >/dev/null || pip install configobj

######################################################################
#
######################################################################

cat <<'__EOT__' >myini.py
#!/usr/bin/env python

# Usage:
# python myini.py --myini `pwd`/my.ini
# python myini.py --dryrun --myini `pwd`/my.ini

import re
import socket
import os
import argparse

# http://www.voidspace.org.uk/python/configobj.html
from configobj import ConfigObj

parser = argparse.ArgumentParser()
parser.add_argument("-m", "--myini",help="path to my.ini")
parser.add_argument("-dr", "--dryrun",help="read config file and write it back out without modifying config.  This allows configobj to do whitespace cleanup.")
args = parser.parse_args()

if args.myini:
    if not os.path.exists(args.myini):
        parser.error("I can't find %s, quitting prematurely" % (args.myini))

config = ConfigObj( os.path.join( os.path.dirname(os.path.realpath(__file__)), args.myini) )


if args.dryrun:
    config.write()
    exit()

def privateip():
    # http://stackoverflow.com/a/274644/1495086
    import netifaces

    for interface in netifaces.interfaces():
        addrs = netifaces.ifaddresses(interface)
        try:
            for link in netifaces.ifaddresses(interface)[netifaces.AF_INET]:
                ip = link['addr']
                if not (ip == '127.0.0.1' or ip == '0.0.0.0'):
                    return ip
        except Exception as e:
            pass

def getip():
    # return privateip()
    return socket.gethostbyname("{{opposing_server_ip_not_mine}}")

# http://is.gd/2QvY0m
# FIXME: How can we remove 'log_bin' all together using ConfigObj or other
# c.has_option("mysqld","log_bin") and c.remove_option("mysqld","log_bin")

# https://www.linode.com/docs/databases/mysql/mysql-master-master-replication

# http://www.lefred.be/node/45
# config['mysqld']['master-user'] 		     = '{{mysql_repl_username}}';
# config['mysqld']['master-password'] 		     = '{{mysql_repl_pass}}';
# config['mysqld']['master-port'] 		     = 3306

##############################
try:
	del config['mysqld']['master-port']
except Exception as e:
	pass


try:
	del config['mysqld']['master-password']
except Exception as e:
	pass

try:
	del config['mysqld']['master-user']
except Exception as e:
	pass

try:
	del config['mysqld']['master-host']
except Exception as e:
	pass
# # config['mysqld']['master-host'] 		     = socket.gethostbyname("{{opposing_server_ip_not_mine}}")
##############################



config['mysqld']['server_id'] 		     = {{mysql_server_id}}
config['mysqld']['log_bin'] 		     = 'mysql-bin.log'
config['mysqld']['binlog_format']	     = 'ROW'
config['mysqld']['slave-skip-errors']	     = '1050,1062,1032'
config['mysqld']['sync_binlog']             = 1
config['mysqld']['log_bin_index'] 	     = 'mysql-bin.log.index'
config['mysqld']['relay_log'] 		     = 'mysql-relay-bin'
config['mysqld']['relay_log_index'] 	     = 'mysql-relay-bin.index'
config['mysqld']['max_binlog_size'] 	     = '100M'
config['mysqld']['expire_logs_days'] 	     = 10
config['mysqld']['log_slave_updates'] 	     = 1
config['mysqld']['auto-increment-increment'] = 2
config['mysqld']['auto-increment-offset']    = 1

config['mysqld']['replicate-do-db']          = '{{database_to_replicate}}'
#config['mysqld']['replicate-do-db']          = 'mysql'
config['mysqld']['replicate-ignore-table']   = 'streambox_live.slsconfig'

# From Vay's config:
# # Replication
# skip-slave-start
# #required for circular replication with more than two nodes setup
# log-slave-updates = 1
# replicate-same-server-id = 0
# #Tells the slave thread to continue replication when a query returns an error from the provided list.
# expire_logs_days = 10
# log-bin = replicate-bin
# binlog_format = ROW
# slave-skip-errors = 1050,1062,1032
# sync_binlog = 1

config['mysqld']['replicate-same-server-id'] = 'FALSE'
config['mysqld']['log-slave-updates'] = 'TRUE'
config['mysqld']['skip-slave-start'] = 'TRUE'




try:
	del config['mysqld']['bind-address']
except Exception as e:
	pass

config.write()





##############################
# Create SQL script to add mysql dba
##############################
heredoc="""

-- this works to delete user from localhost and from '%', but not from
-- all hosts explicitely defined such as sls_repl@54.193.253.35 for
-- example.
delete from mysql.user WHERE User = '{{mysql_repl_username}}';
grant usage on *.* to '{{mysql_repl_username}}'@'localhost';
drop user '{{mysql_repl_username}}'@'localhost';
grant usage on *.* to '{{mysql_repl_username}}'@'%';
drop user '{{mysql_repl_username}}'@'%';

-- this deletes the user from all hosts:
SET SQL_SAFE_UPDATES = 0;
delete from mysql.user WHERE User = 'sls_repl';

-- Add user back in
-- GRANT REPLICATION SLAVE,replication client ON *.* TO '{{mysql_repl_username}}'@'{other_server_ip}' IDENTIFIED BY '{{mysql_repl_pass}}';
-- show grants for '{{mysql_repl_username}}'@'{other_server_ip}';

-- http://stackoverflow.com/a/5016587/1495086
-- don't do this in production, but helpful for debug to give full
-- rights to user:
GRANT ALL PRIVILEGES ON streambox_live.* TO '{{mysql_repl_username}}'@'%' WITH GRANT OPTION;

flush privileges;

-- # Localhost
-- create user '{{mysql_repl_username}}'@'localhost' IDENTIFIED BY '{{mysql_repl_password}}';
-- grant all privileges on *.* to '{{mysql_repl_username}}'@'localhost' with grant option;

-- # Everywhere
-- create user '{{mysql_repl_username}}'@'%' identified by '{{mysql_repl_password}}';
-- grant all privileges on *.* to '{{mysql_repl_username}}'@'%' with grant option;

-- flush privileges;
""".format(other_server_ip=socket.gethostbyname("{{opposing_server_ip_not_mine}}"))

with open("otkqummaiujtea.sql", "w") as w:
    w.write(heredoc)
__EOT__

######################################################################
#
######################################################################

# cd /c/MySQL
python /tmp/myini.py --myini /c/MySQL/my.ini
chmod 700 otkqummaiujtea.sql

set +e
net stop mysql
set -e

# # eg /d/mysqldata/mysql-bin.000063
# rm -f /d/mysqldata/mysql-bin.[0-9][0-9][0-9][0-9][0-9][0-9]*
# rm -f /d/mysqldata/mysql-bin.log.index
# rm -f /d/mysqldata/mysql-relay-bin.[0-9][0-9][0-9][0-9][0-9][0-9]*
# rm -f /d/mysqldata/mysql-relay-bin.index

net start mysql

mysql \
    --table \
    --host=127.0.0.1 \
    --database=mysql \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <otkqummaiujtea.sql

######################################################################
#
######################################################################
# slave
if test {{mysql_server_id}} -eq 2
then
    cat <<'__EOT__' >'server_id2.sql'
-- RESET SLAVE;
show master status\G
__EOT__
    mysql \
	--table \
	--host=127.0.0.1 \
	--database=mysql \
	--user={{mysql_user}} \
	--password='{{mysql_user_pass}}' <server_id2.sql >server_id2.out

    f=$(cat server_id2.out | grep 'File: ' | cut -d: -f2- | tr -d ' ')
    p=$(cat server_id2.out | grep 'Position: ' |
	       cut -d: -f2- | tr -d ' ')
    {
	perl -e 'print qq/-- run this on master ({{server1}})\n/'
	echo CHANGE MASTER TO MASTER_HOST=\'{{server2_ip}}\', MASTER_USER=\'{{mysql_repl_username}}\', MASTER_PASSWORD=\'{{mysql_repl_pass}}\', MASTER_LOG_FILE=\'$f\', MASTER_LOG_POS=$p\;
	echo start slave\;
	echo show slave status\\G

    } >run_on_{{server1}}_autogen.sql

    rm -f server_id2.sql
    rm -f server_id2.out
fi

# master
if test {{mysql_server_id}} -eq 1
then
    cat <<'__EOT__' >'server_id1.sql'
-- RESET SLAVE;
show master status\G
__EOT__
    mysql \
	--table \
	--host=127.0.0.1 \
	--database=mysql \
	--user={{mysql_user}} \
	--password='{{mysql_user_pass}}' <server_id1.sql >server_id1.out

    f=$(cat server_id1.out | grep 'File: ' | cut -d: -f2- | tr -d ' ')
    p=$(cat server_id1.out | grep 'Position: ' |
	       cut -d: -f2- | tr -d ' ')

    {
	perl -e 'print qq/-- run this on slave ({{server2}})\n/'
	echo CHANGE MASTER TO MASTER_HOST=\'{{server1_ip}}\', MASTER_USER=\'{{mysql_repl_username}}\', MASTER_PASSWORD=\'{{mysql_repl_pass}}\', MASTER_LOG_FILE=\'$f\', MASTER_LOG_POS=$p\;
	echo start slave\;
	echo show slave status\\G
    } >run_on_{{server2}}_autogen.sql

    rm -f server_id1.sql
    rm -f server_id1.out
fi



######################################################################
#
######################################################################
