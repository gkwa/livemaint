#!/bin/sh

echo cat master_is_t2_slave_is_t3_autogen.sh

ls for_t[23]_master_is_t2_slave_is_t3_*autogen.sh* |
    while read f;
    do
	echo cat $f
    done;


echo cat t2_t3_swap_sql_autogen.sh
echo cat t2_t3_represet_autogen.sh
echo cat t3_t2_represet_autogen.sh
echo cat t3_t2_represet_controll_autogen.sh
echo cat t2_t3_represet_controll_autogen.sh
echo cat run_on_t3_autogen.sql
echo cat run_on_t2_autogen.sql


{
    for f in for_t2_master_is_t2_slave_is_t3_autogen.sh.log \
		 for_t3_master_is_t2_slave_is_t3_autogen.sh.log
    do
	[ -f $f ] && cat $f
    done

} | grep -iE 'CHANGE MASTER TO |start slave|show slave status|run this on'
