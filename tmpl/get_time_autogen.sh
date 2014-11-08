#!/bin/sh

unset HISTFILE

epoch=$(date +%s)
utc=$(date -u)

printf "%s\t%s" "$epoch" "$utc"
