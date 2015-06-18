#!/bin/sh

unset HISTFILE

cd /tmp

trap "rm -f {{scrBase}}.sql; exit" HUP INT QUIT TERM EXIT



cat << '__EOT__' >{{scrBase}}.sql
USE {{database}};

-- if @ghost_duration_hours hours have passed between now() and stream's
-- start_time, then stream is ghost

SET @ghost_duration_hours := 10;

DROP TABLE IF EXISTS ghost_streams;

CREATE temporary TABLE IF NOT EXISTS ghost_streams AS
  (SELECT ROUND(( UNIX_TIMESTAMP(NOW()) - start_time ) / 60 / 60, 2) AS hours,
          title,
          contributor,
          location,
          file_id,
          dt_update,
          dt_created,
          is_complete,
          is_active,
          transporter_ip,
          fname,
          encoder_ip,
          encoder_port,
          connectivity,
          producer,
          network1,
          network2,
          network3,
          hw,
          vid_width,
          vid_height,
          bitrate,
          audio,
          ch,
          tfps,
          encoder_version,
          transporter_port,
          live_version,
          sold,
          price,
          user_id,
          drm_id,
          dtime,
          fsize,
          last_status,
          start_time,
          stop_time,
          start_time_s,
          has_jpg,
          has_flv,
          has_ogg,
          has_mp4,
          has_mp4_full,
          dng_serial,
          preset_name,
          dng_name,
          dmeta,
          gps_x,
          gps_y,
          gps_x_end,
          gps_y_end
   FROM   file
   WHERE  is_active = 1
          AND is_complete = 0
   HAVING hours > @ghost_duration_hours
   LIMIT  100);

SELECT *
FROM   ghost_streams;

__EOT__

mysql \
    --table \
    --host=127.0.0.1 \
    --user={{mysql_user}} \
    --password='{{mysql_user_pass}}' <{{scrBase}}.sql 2>&1 | \
    grep -vi 'Warning: Using a password on the command line interface can be insecure.'
