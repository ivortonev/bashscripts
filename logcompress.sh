#!/bin/bash

DATA=`/bin/date +%Y-%m-%d`
FILES=`/usr/bin/find . -type f | /bin/grep -v $DATA | /bin/grep log$ | /usr/bin/sort -n`
COMPRESS="/usr/bin/xz -z -9 -e "
LOGDIR="/srv/syslog"
SUM="/usr/bin/sha512sum"

cd $LOGDIR

for i in $FILES ; do $SUM $i >> $i.sha512 ; done

$COMPRESS $FILES
