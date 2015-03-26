livemaint
=========
requires these tools:
* dos2unix, unix2dos
* Gnu Parallel
* python module Jinja2

# Usage examples

#### compare mysql schema between t1 and t3 ####
Show me the changes that must be made to server t3 mysql schema to make it look like server t1.
 ```
 make clean && gens --sandbox --mysqlAddTempDBA && sh mysql_remote_admin_add_autogen_all.sh
 make clean && gens --sandbox --mysqldbcompare && sh -x mysql_check_from_t3_to_t1_controller_autogen.sh
 # remove dba, but don't clean or else you'll loose the log file just generaged
 gens --sandbox --mysqlRemoveTempDBA && sh mysql_remote_admin_remove_autogen_all.sh
 cat mysqldbcompare_autogen_t3_to_t1_autogen.sh.log
 ```
