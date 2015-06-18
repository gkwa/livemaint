#!/bin/sh

: '

This script has problems:

* it assumes credentials for these users (sls_cron, sls_repl, etc) are
  the same for all the replication servers.

Instead of this:

SET SQL_SAFE_UPDATES = 0;
UPDATE streambox_live.transporter SET server_password=TO_BASE64("{{mysql_sls_repl_pass}}") WHERE transporter.server_login="sls_repl";

Every server in the replication ring has a transporter table with
sls_repl / password for each server.

'


# cron
# php
# repl
# report

unset HISTFILE

trap "rm -f $0.$$.tmp {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp

cat <<'__EOT__' >$0.$$.tmp
sed -i.bak -e 's,^mysql.default_password.*=.*,mysql.default_password = {{mysql_sls_php_pass}},' /c/php/php.ini
net stop apache2.4
net start apache2.4
__EOT__
sh $0.$$.tmp &

if test ! -z "$(env | grep WINDIR)"
then
    # Windows

    cat <<'__EOT__' >{{scrBase}}.sql

	UPDATE mysql.User SET Password=PASSWORD('{{mysql_user_pass}}') WHERE User='root';
	UPDATE mysql.User SET Password=PASSWORD('{{mysql_sls_cron_pass}}') WHERE User='sls_cron';
	UPDATE mysql.User SET Password=PASSWORD('{{mysql_sls_php_pass}}') WHERE User='sls_php';
	UPDATE mysql.User SET Password=PASSWORD('{{slsreport_mysql_pass}}') WHERE User='sls_report';
	UPDATE mysql.User SET Password=PASSWORD('{{mysql_sls_repl_pass}}') WHERE User='sls_repl';

	-- for comment on stdout
	SELECT 'mysql.User' AS '';

	SELECT
		 User, Password, Host
	FROM
	    mysql.User
	WHERE
	    (User = 'sls_exe' OR User = 'sls_cron' OR User = 'sls_php' OR User = 'sls_repl');

__EOT__

else

    # Linux

    cat <<'__EOT__' >{{scrBase}}.sql

	UPDATE mysql.user SET Password=PASSWORD('{{mysql_user_pass}}') WHERE User='root';
	UPDATE mysql.user SET Password=PASSWORD('{{mysql_sls_cron_pass}}') WHERE User='sls_cron';
	UPDATE mysql.user SET Password=PASSWORD('{{mysql_sls_php_pass}}') WHERE User='sls_php';
	UPDATE mysql.user SET Password=PASSWORD('{{slsreport_mysql_pass}}') WHERE User='sls_report';
	UPDATE mysql.user SET Password=PASSWORD('{{mysql_sls_repl_pass}}') WHERE User='sls_repl';

	-- for comment on stdout
        SELECT 'mysql.user' AS '';

        SELECT
		 User, Password, Host
        FROM
            mysql.user
        WHERE
            (user = 'sls_exe' OR user = 'sls_cron' OR user = 'sls_php' OR user = 'sls_repl');

__EOT__

fi

cat <<'__EOT__' >>{{scrBase}}.sql

-- Error Code: 1175. You are using safe update mode and you tried to
-- update a table without a WHERE that uses a KEY column To disable safe
-- mode, toggle the option in Preferences -> SQL Queries and
-- reconnect. 0.000 sec
SET SQL_SAFE_UPDATES = 0;

UPDATE streambox_live.user SET pass='{{streambox_live_sls_exe_pass}}' WHERE login='sls_exe';
UPDATE streambox_live.user SET pass='{{streambox_live_webui_admin_pass}}' WHERE login='admin';

-- ------------------------------
-- Insert to slsconfig only if the values don't already exist
-- ------------------------------
-- FIXME: this seems way too convoluted
-- https://tricksbynazir.wordpress.com/2013/12/26/mysql-insert-record-if-not-exists-in-table/

SET SQL_SAFE_UPDATES = 0;

-- slscron_mysql_user
-- slscron_mysql_pass
INSERT INTO streambox_live.slsconfig (name, value, dt_update) SELECT * FROM (SELECT 'slscron_mysql_user', 'sls_cron', NOW()) AS tmp
WHERE NOT EXISTS (SELECT name FROM streambox_live.slsconfig WHERE name='slscron_mysql_user') LIMIT 1;
INSERT INTO streambox_live.slsconfig (name, value, dt_update) SELECT * FROM (SELECT 'slscron_mysql_pass', '{{mysql_sls_cron_pass}}', NOW()) AS tmp
WHERE NOT EXISTS (SELECT name FROM streambox_live.slsconfig WHERE name='slscron_mysql_pass') LIMIT 1;
UPDATE streambox_live.slsconfig SET value='{{mysql_sls_cron_pass}}' WHERE name='slscron_mysql_pass';

-- slsreport_mysql_user
-- slsreport_mysql_pass
INSERT INTO streambox_live.slsconfig (name, value, dt_update) SELECT * FROM (SELECT 'slsreport_mysql_user', 'sls_report', NOW()) AS tmp
WHERE NOT EXISTS (SELECT name FROM streambox_live.slsconfig WHERE name='slsreport_mysql_user') LIMIT 1;
INSERT INTO streambox_live.slsconfig (name, value, dt_update) SELECT * FROM (SELECT 'slsreport_mysql_pass', '{{slsreport_mysql_pass}}', NOW()) AS tmp
WHERE NOT EXISTS (SELECT name FROM streambox_live.slsconfig WHERE name='slsreport_mysql_pass') LIMIT 1;
UPDATE streambox_live.slsconfig SET value='{{slsreport_mysql_pass}}' WHERE name='slsreport_mysql_pass';

SELECT PASSWORD('{{mysql_sls_php_pass}}');

--

-- Error Code: 1175. You are using safe update mode and you tried to
-- update a table without a WHERE that uses a KEY column To disable safe
-- mode, toggle the option in Preferences -> SQL Queries and
-- reconnect. 0.000 sec
SET SQL_SAFE_UPDATES = 0;
UPDATE streambox_live.transporter SET server_password=TO_BASE64('{{mysql_sls_repl_pass}}') WHERE transporter.server_login='sls_repl';

--

SELECT 'streambox_live.user' AS '';

SELECT
	login, pass, user_id
FROM
    streambox_live.user
WHERE
    (login = 'sls_exe' OR login = 'sls_cron' OR login = 'sls_php' OR
	login = 'sls_repl' OR login = 'admin');


FLUSH PRIVILEGES;

__EOT__

mysql --table -h127.0.0.1 \
      --user={{mysql_user}} \
      --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 | \
    grep -vi 'Warning: Using a password on the command line interface can be insecure.'
