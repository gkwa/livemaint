#!/bin/sh
set -e
unset HISTFILE

cd /tmp

# trap "sudo chown $(id -u):$(id -g) {{report_outfile_path_mysql}}||:; rm -f {{report_outfile_path_mysql}} {{scrBase}}.sql; exit" HUP INT QUIT TERM

rm -f '{{report_outfile_path_cygwin}}'

cat <<'__EOT__' >{{scrBase}}.sql

use {{database}};

-- Apache/htdocs/ls/includes/inc_client_vars.js
-- var ACCT_NEW = 1;
-- var ACCT_ACTIVATED = 2;
-- var ACCT_EXPIRED = 3;
-- var ACCT_DISABLED = 4;
-- var ACCT_COLD = 5;
-- var ACCT_HOT = 6;
-- var ACCT_EXPIRING = 7;
-- var ACCT_MAXED = 8;
-- var ACCT_PASS_CHANGE = 9;

DROP temporary TABLE IF EXISTS tmpaccttype;

CREATE temporary TABLE IF NOT EXISTS tmpaccttype
  (
     id       INT(11) NOT NULL auto_increment,
     typecode INT(11) NOT NULL,
     type     VARCHAR(60) NOT NULL UNIQUE,
     PRIMARY KEY(id)
  )
engine=memory;

INSERT INTO tmpaccttype (typecode,type) VALUES (1,'New');
INSERT INTO tmpaccttype (typecode,type) VALUES (2,'Activated');
INSERT INTO tmpaccttype (typecode,type) VALUES (3,'Expired');
INSERT INTO tmpaccttype (typecode,type) VALUES (4,'Disabled');
INSERT INTO tmpaccttype (typecode,type) VALUES (5,'Cold');
INSERT INTO tmpaccttype (typecode,type) VALUES (6,'Hot');
INSERT INTO tmpaccttype (typecode,type) VALUES (7,'Expiring');
INSERT INTO tmpaccttype (typecode,type) VALUES (8,'Maxed');
INSERT INTO tmpaccttype (typecode,type) VALUES (9,'Pass Change required');
-- select * from tmpaccttype;

-- Apache/htdocs/ls/includes/inc_client_vars.js
-- var ACC_CONTRIBUTOR = "2";
-- var ACC_ADMIN = "1";
-- var ACC_USER = "0";
-- var ACC_STREAMBOX = "-1";

DROP temporary TABLE IF EXISTS tmpusertype;

CREATE temporary TABLE IF NOT EXISTS tmpusertype
  (
     id       INT(11) NOT NULL auto_increment,
     typecode INT(11) NOT NULL,
     type     VARCHAR(60) NOT NULL UNIQUE,
     PRIMARY KEY(id)
  )
engine=memory;

INSERT INTO tmpusertype (typecode,type) VALUES (2,'contributor');
INSERT INTO tmpusertype (typecode,type) VALUES (1,'group.admin');
INSERT INTO tmpusertype (typecode,type) VALUES (0,'operator');
INSERT INTO tmpusertype (typecode,type) VALUES (-1,'sysadmin');
-- select * from tmpusertype;

SELECT
    user_id,
    login,
    fn,
    ln,
    company,
    email,
    drm,
    (SELECT
            tmpusertype.type
        FROM
            tmpusertype
        WHERE
            tmpusertype.typecode = view_users.type_id) AS Type,
    (SELECT CONCAT('$', FORMAT(cash, 2))) AS Cash,
    (SELECT CONCAT('$', FORMAT(tax, 5))) AS Cost,
    DATE_FORMAT(dt_created, '%m/%d/%Y') AS Created,
    (SELECT DATEDIFF(NOW(), dt_update)) AS 'Last Accessed',
    (SELECT
            tmpaccttype.type
        FROM
            tmpaccttype
        WHERE
            tmpaccttype.typecode = view_users.acct_status) AS Status
FROM
    view_users
WHERE
    (is_active = '1') AND drm LIKE '{{search_drm}}'
-- LIMIT 0 , 10;
INTO OUTFILE '{{report_outfile_path_mysql}}'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
__EOT__

mysql --host=127.0.0.1 \
      --user={{mysql_user}} \
      --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 |
    grep -vi 'Warning: Using a password on the command line interface can be insecure.'
