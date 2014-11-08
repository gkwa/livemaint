#!/bin/sh

if test ! -z "$(env | grep WINDIR)"
then
    # Windows

    # PHP.ini
    grep error_reporting /c/php/php.ini
    sed -i.bak -e 's,^error_reporting *=.*,error_reporting = E_ALL,' /c/php/php.ini
    rm -f /c/php/php.ini.bak
    grep error_reporting /c/php/php.ini

    # Apache httpd.conf
    grep -i loglevel /c/Apache/conf/httpd.conf
    sed -i.bak -e 's,LogLevel emerg,LogLevel info,' /c/Apache/conf/httpd.conf
    grep -i loglevel /c/Apache/conf/httpd.conf
    rm -f /c/Apache/conf/httpd.conf.bak
    /c/Apache/bin/httpd.exe -k restart
fi


