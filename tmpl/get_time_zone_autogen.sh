#!/bin/sh

unset HISTFILE

if test -z "$(env | grep WINDIR)"
then
    # Windows
    systeminfo | findstr /C:"Time Zone"
fi
