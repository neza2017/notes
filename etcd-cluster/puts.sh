#!/bin/bash

IP1=$(docker exec machine-1 cat /etc/hosts | grep "machine-1" | awk '{print $1}')
IP2=$(docker exec machine-2 cat /etc/hosts | grep "machine-2" | awk '{print $1}')
IP3=$(docker exec machine-3 cat /etc/hosts | grep "machine-3" | awk '{print $1}')

ENDPOINTS=$IP1:2379,$IP2:2379,$IP3:2379

echo "endpoints : $ENDPOINTS"
etcdctl --endpoints=$ENDPOINTS member list -w table

BEGIN=0
if [ $# -eq 1 ]; then
    END=$1
elif [ $# -eq 2 ]; then
    BEGIN=$1
    END=$2
else
    echo "usage puts.sh [begin] <end>"
    exit -1
fi

while [ $BEGIN -lt $END ]; do
    etcdctl --endpoints=$ENDPOINTS put key${BEGIN} value${BEGIN}
    echo $BEGIN
    BEGIN=$[$BEGIN + 1]
done

echo "endpoints : $ENDPOINTS"
