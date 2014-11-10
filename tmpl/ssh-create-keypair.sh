#!/bin/sh

# usage example: $0 livering
# usage example: $0 test

# Purpose: create an ssh keypair in ~/.ssh with random passphrase

# [demo@demos-MacBook-Pro:~/pdev/lstest/server_maint/tmpl(ins)]$ ./ssh-create-keypair.sh livering
# /Users/demo/.ssh/livering-20141105
# /Users/demo/.ssh/livering-20141105.pub
# passphrase:
# U/53TIo2SxY
# [demo@demos-MacBook-Pro:~/pdev/lstest/server_maint/tmpl(ins)]$

basename="$1"
if test -z "$basename"
then
    basename="{{key_basename}}"

    if test -z "$basename"
    then
	echo "Quitting prematurely, '$basename' is empty"
	exit 1
    fi
fi

dir=~/.ssh
d=$(date +%Y%m%d)

mkdir -p $dir
rm -f "$dir/${basename}-$d"
rm -f "$dir/${basename}-$d.pub"
key="$(openssl rand 8 -base64|sed -e 's,=*$,,')"
ssh-keygen -q -P "$key" -t rsa -f "$dir/${basename}-$d" -C "${basename}-$d"
chmod -R 600 "$dir/${basename}-$d"
ls $dir/${basename}-$d*

printf "passphrase:\n$key\n"

echo '# ls ~/.ssh'
printf '# rm -f %s*\n' "$dir/${basename}-$d"