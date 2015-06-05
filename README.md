livemaint
=========
requires these tools:
* dos2unix, unix2dos
* Gnu Parallel
* python module Jinja2

#### Import ####
 ```
 # Import example
 ssh t1 'mkdir -p /c/sls_db/sb_backup'
 make clean && gens --production --mysqldump
 sh -x mysqldump_autogen_LiveDB_controller.sh
 zip=$(ssh db 'ls -t /tmp/*.zip | head -1')
 scp db:$zip /tmp
 ssh t1 mkdir -p /c/sls_db/sb_backup
 scp $zip t1:/c/sls_db/sb_backup
 # manually edit tmpl/mysqldump_import_streambox_live_autogen.sh to include hard-coded value of $zip
 make clean && gens -s --mySQLImportStreamboxLiveDBFromFile && sh -x mysqldump_import_streambox_live_autogen_t1_controller.sh
 gens -s --mysqlUserCredsUpdate  && sh -x mysql_update_and_check_accounts_autogen_t1_controller.sh

 # todo: should automate this
 server_ip
 server_domain_name
 site_name
 purge_file_on_delete=1
 ```
