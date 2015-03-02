#!/bin/sh

# http://superuser.com/questions/310437/how-can-i-determine-which-version-of-windows-is-running-on-a-server-using-powers

if test -z "$(env | grep WINDIR)"
then
    uname -a
else
    {
	powershell -NoProfile -ExecutionPolicy bypass -command '(gwmi win32_operatingSystem | select caption).caption'
    } 2>&1
fi
