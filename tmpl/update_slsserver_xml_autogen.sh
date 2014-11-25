#!/bin/sh

set -e


# If we're not on windows, then abort
if test -z "$(uname -s|grep CYGWIN)"
then
    exit 0;
fi




cd /tmp

cat << '__EOT__' >{{scrBase}}.php
<?php

$shortopts = "";
$longopts  = array("in_xml_abs_path:", "out_xml_abs_path:",);

$options = getopt($shortopts, $longopts);

$dom=new DOMDocument;
$dom->preserveWhiteSpace=true;
$dom->formatOutput=true;

$dom->load($options['in_xml_abs_path']);
$xpath=new DOMXPath($dom);

$storage=$xpath->query("/body/storage")->item(0);

////////////////////////////////////////////////////
// only set the value if its not already set
////////////////////////////////////////////////////
if(!$storage->hasAttribute("data_drive")) {
  $storage->setAttribute("data_drive","{{data_drive}}");
}

////////////////////////////////////////////////////
// set the value no matter what
////////////////////////////////////////////////////
$storage->setAttribute('act_port','80');
$storage->setAttribute('actl3trans','c:\\SLS_DB\\actl3trans\\transcoder.exe');
$storage->setAttribute('archive','yes');
$storage->setAttribute('bc_store_url','https://store.streambox.com');
$storage->setAttribute('bc_username','liveserver');
$storage->setAttribute('convert_amt','1');
$storage->setAttribute('email_from','sender@streambox.com');
$storage->setAttribute('email_to_override','');
$storage->setAttribute('flash_amount','10');
$storage->setAttribute('flash_max','600');
$storage->setAttribute('frames','1000');
$storage->setAttribute('frames_thumb','1000');
$storage->setAttribute('ldmp_proto','1');
$storage->setAttribute('limiter','2');
$storage->setAttribute('mp4','c:\\SLS_DB\\wrappers\\exit_with_success.cmd');
$storage->setAttribute('mysql_backup_host','{{mysql_backup_host}}');
$storage->setAttribute('mysql_backup_pass','{{mysql_backup_pass}}');
$storage->setAttribute('nopic','nopic2.jpg');
$storage->setAttribute('ogg','c:\\SLS_DB\\wrappers\\exit_with_success.cmd');
$storage->setAttribute('path','c:\\Apache\\htdocs\\ls\\actl3files');
$storage->setAttribute('play','c:\\SLS_DB\\mplayer\\mplayer.exe');
$storage->setAttribute('preview','c:\\SLS_DB\\wrappers\\mcwrap_mov_mp4.cmd');
$storage->setAttribute('smtp_login','sender@streambox.com');
$storage->setAttribute('tc_create_wait_sec','600');
$storage->setAttribute('thumb_amount','20');
$storage->setAttribute('thumb_max','300');
$storage->setAttribute('tnc_server','http://54.245.163.78:1926');
$storage->setAttribute('webpath','c:\\Apache\\htdocs\\ls\\actl3files');

////////////////////////////////////////////////////
// remove attributes
////////////////////////////////////////////////////
$storage->removeAttribute('test');

$dom->save($options['out_xml_abs_path']);

?>
__EOT__




/c/php/php.exe --no-php-ini --file {{scrBase}}.php -- \
    --in_xml_abs_path 'c:\SLS_DB\SLSServer.xml' \
    --out_xml_abs_path 'c:\SLS_DB\SLSServer.xml'

perl -i -p -e 's{\n}{\r\n}' 'c:\SLS_DB\SLSServer.xml'

rm -f {{scrBase}}.php
