#!/bin/sh

for f in get_cron_job_list_autogen_*_autogen_csplit_*
do
    if test ! -z "$(grep -i sls_ $f)"
    then
	hostname="$(grep -Ei '^hostname' $f)"
	task="$(grep -Ei '^Task To Run:' $f)"
	printf '%s\n\t%s' $hostname "$task"
    fi
done
