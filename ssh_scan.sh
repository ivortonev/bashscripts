#!/bin/bash

IP=$1
DATE=`/bin/date +%Y-%m-%d`

/bin/mkdir $DATE >/dev/null 2>/dev/null

/bin/nc -w 10 -z $IP 22

if [ $? -eq 0 ] ; then
                echo "$IP com SSH ativo ! "
                echo $IP >> $DATE/ssh_hosts
        else
                echo "$IP nao responde ... "
fi
