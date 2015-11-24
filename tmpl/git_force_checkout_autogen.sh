#!/bin/sh

cd /c

git fetch --prune

if git show-ref --quiet --verify "refs/heads/{{branch}}"
then
	git checkout --force "{{branch}}"
else
	git checkout --force --track "origin/{{branch}}"
fi

git reset --hard "origin/{{branch}}"
