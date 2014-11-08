#!/bin/sh

if test ! -z "$(env | grep WINDIR)"
then
    # Windows
    tail -5000 /c/Apache/logs/access.log |
    sed -e 's,^,{{server}} access.log ,'
    tail -5000 /c/Apache/logs/error.log |
    sed -e 's,^,{{server}} error.log ,'

fi


