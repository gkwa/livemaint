if test ! -z "$(uname -s|grep CYGWIN)"
then
    # Windows
    [ -d /d ] && df -h /c /d | sed -e 's,^,{{server}}	,'
    [ -d /e ] && df -h /c /e | sed -e 's,^,{{server}}	,'
else
    # Linux
    df -h | sed -e 's,^,{{server}}	,'
fi
