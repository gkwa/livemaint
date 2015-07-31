#!/bin/sh

# FIXME: Although this seems to clear the decoders tab, we're not doing
# enough here.  you need to do more.

# you need to
# SET GLOBAL general_log = 'on'

# and watch more.  These sql updates arent nearly doing as much as the
# backend is when things are working.




unset HISTFILE

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT

cd /tmp
cat << __EOT__ >{{scrBase}}.sql

-- Select from view_decoders feeds that are still routed (is_routed=1)
-- and mark them as un routed (is_routed='').  Create tempoary table to
-- handle this since you can update in subquery.  Temp table is expunged
-- by MySQL when session ends.

set @previous_mode := (select @@sql_safe_updates);
select @@sql_safe_updates;
SET SQL_SAFE_UPDATES = 0;


CREATE TEMPORARY TABLE IF NOT EXISTS decoders_routed_tmp AS (
SELECT
    *
FROM
    view_decoders
WHERE
    is_active = 1 AND
    user_is_active = 1 AND
    is_routed = 1
ORDER BY decoder ASC , dt_created ASC
);

-- for log, show how many we're expunging
select * from decoders_routed_tmp;

UPDATE decoder
SET
    is_routed = ''
WHERE
    decoder_id IN (SELECT
            decoder_id
        FROM
            decoders_routed_tmp);

-- return safe mode back to previous state
SET SQL_SAFE_UPDATES = @previous_mode;
select @@sql_safe_updates;

__EOT__

mysql \
    --table \
    --database={{database}} \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 | grep -vi 'Warning: Using a password on the command line interface can be insecure.'
rm -f {{scrBase}}.sql
