#!/bin/sh

unset HISTFILE

if test ! -z "$(env | grep WINDIR)"
then
    # Windows
    schtasks /query /fo list /v

else
    # Linux
    crontab -l

fi
