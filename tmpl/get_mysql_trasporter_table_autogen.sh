#!/bin/sh

unset HISTFILE

cd /tmp
cat << __EOT__ >{{scrBase}}.sql

-- SELECT * FROM transporter WHERE is_active=1 ORDER BY transporter;

-- --------------------------------------------------

-- SELECT domain_name FROM transporter WHERE is_active=1 ORDER BY ip;

-- --------------------------------------------------

-- SELECT DISTINCT domain_name FROM transporter WHERE is_active=1 ORDER BY ip;

-- --------------------------------------------------

-- SELECT transporter,ip,domain_name,user_id,type_id,sql_master_id,server_password,is_active FROM transporter WHERE is_active=1 ORDER BY ip;

-- --------------------------------------------------

-- SELECT rpad(is_active,2,' '),rpad(ip,16,' '),rpad(transporter,25,' '),rpad(sql_master_id,6,' '),rpad(server_password,10,' ') FROM transporter WHERE is_active=1 AND sql_master_id<>0 ORDER BY sql_master_id;

-- --------------------------------------------------

-- SELECT rpad(is_active,2,' '),rpad(ip,16,' '),rpad(transporter,25,' '),rpad(sql_master_id,6,' '),rpad(server_password,10,' ') FROM transporter  WHERE sql_master_id<>0  ORDER BY sql_master_id;

-- --------------------------------------------------

-- SELECT rpad(is_active,2,' '),rpad(ip,16,' '),rpad(transporter,25,' '),rpad(sql_master_id,6,' '),rpad(server_password,10,' ') FROM transporter ORDER BY sql_master_id;

-- --------------------------------------------------

-- SELECT * FROM transporter WHERE is_active=1 ORDER BY transporer_id\\G;

-- --------------------------------------------------

/*
SELECT \
transporter_id, \
transporter, \
ip, \
domain_name, \
sql_master_id \
FROM transporter WHERE is_active=1 ORDER BY transporter_id\\G;
*/

-- --------------------------------------------------

/*
SELECT \
transporter_id, \
transporter, \
ip, \
domain_name, \
sql_master_id \
FROM transporter
WHERE \
is_active=1 and  \
transporter like '%MySQL%' \
ORDER BY transporter_id\\G;
*/

-- --------------------------------------------------

/*
SELECT
    transporter,
    transporter_id,
    sql_master_id as masterid,
    (SELECT
            transporter
        FROM
            transporter
        WHERE
            masterid = transporter_id) AS Master
FROM
    transporter
WHERE
    transporter LIKE '%MySQL%'
AND
    is_active=1
*/

-- --------------------------------------------------

/*
SELECT \
transporter_id \
FROM transporter WHERE is_active=1 ORDER BY transporer_id\\G;
*/

-- --------------------------------------------------

/*
-- Fixed width header is easier to read
SELECT rpad(is_active,2,' '),rpad(ip,16,' '),rpad(transporter,25,' '),rpad(sql_master_id,6,' '),rpad(server_password,10,' ')
FROM transporter
WHERE is_active=1 AND port<>0
ORDER BY ip;
*/

-- --------------------------------------------------

/*
SELECT rpad(is_active,2,' '),rpad(ip,16,' '),rpad(transporter,25,' '),rpad(server_password,10,' ')
FROM transporter
WHERE is_active=1 AND port<>0
ORDER BY ip;
*/
__EOT__

mysql --table -h127.0.0.1 -Dstreambox_live --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' \
    -e '\
select * from transporter \
where port=3306 and \
is_active=1 order by
transporter' 2>&1 | grep -vi 'Warning: Using a password on the command line interface can be insecure.'

mysql --table -h127.0.0.1 -Dstreambox_live --user={{mysql_user}} --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>/dev/null
rm -f {{scrBase}}.sql
