#!/bin/bash

PREFIX="bkp_"
KEEP=4
WORKDIR="/backup"

cd $WORKDIR

for i in $PREFIX ; do
        COUNT=`ls -1 $i* | wc -l`
        while [ $COUNT -gt $KEEP ] ; do
                rm -f `ls -1 $i* | head -n 1`
                COUNT=`ls -1 $i* | wc -l`
        done
done
