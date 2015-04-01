#!/bin/sh

unset HISTFILE

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp

if test ! -z "$(env | grep WINDIR)"
then
    # Windows

    cat <<'__EOT__' >{{scrBase}}.sql


	UPDATE mysql.User SET Password=PASSWORD('{{mysql_sls_cron_pass}}') WHERE User='sls_cron';


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


	UPDATE mysql.user SET Password=PASSWORD('{{mysql_sls_cron_pass}}') WHERE User='sls_cron';


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

UPDATE streambox_live.user SET pass='{{streambox_live_sls_exe_pass}}' WHERE login='sls_exe';
UPDATE streambox_live.user SET pass='{{streambox_live_webui_admin_pass}}' WHERE login='admin';

SELECT PASSWORD('{{mysql_sls_php_pass}}');

--

SELECT 'streambox_live.user' AS '';

SELECT
	login, pass, user_id
FROM
    streambox_live.user
WHERE
    (login = 'sls_exe' OR login = 'sls_cron' OR login = 'sls_php' OR login = 'sls_repl');


FLUSH PRIVILEGES;

__EOT__

mysql --table -h127.0.0.1 \
      --user={{mysql_user}} \
      --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 | \
    grep -vi 'Warning: Using a password on the command line interface can be insecure.'
