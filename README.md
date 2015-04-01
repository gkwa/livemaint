livemaint
=========
requires these tools:
* dos2unix, unix2dos
* Gnu Parallel
* python module Jinja2

#### Import ####
 ```
 # Import example
 ssh t3 'mkdir -p /c/sls_db/sb_backup'
 make clean && gens --production --mysqldump
 sh -x mysqldump_autogen_LiveDB_controller.sh
 ssh db 'ls -t /tmp/*.zip | head -1'
 scp /tmp/mysql_dump_vN_20150401_streambox_live_1427936381.sql.zip t3:/c/sls_db/sb_backup
 make clean && gens -s --mySQLImportStreamboxLiveDBFromFile && sh -x mysqldump_import_streambox_live_autogen_t1_controller.sh
 gens -s --mysqlUserCredsUpdate  && sh -x mysql_update_and_check_accounts_autogen_t1_controller.sh
 ```
