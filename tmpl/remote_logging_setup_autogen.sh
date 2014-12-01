#!/bin/sh

if test ! -z "$(uname -s|grep CYGWIN)"
then
    # Windows
    # on 64bit machine #42 is this: cygpath -u -F 42:/c/Program Files (x86)
    p="$(cygpath -u -F 42)"/nxlog
    [ ! -d "$p" ] && cmd /c cinst nxlog
    cd "$p/conf"

    if test ! -d .git
    then
	git init
	git remote add origin https://github.com/taylormonacelli/nxlogconfig.git
    fi

    git fetch

    head=$(git symbolic-ref --short HEAD)
    if test 'master' != "$head"
    then
	git checkout -f -t origin/master
    fi

    git reset --hard origin/master

    cygrunsrv --stop nxlog
    cygrunsrv --start nxlog
fi
