#!/bin/bash

IP1=$(docker exec machine-1 cat /etc/hosts | grep "machine-1" | awk '{print $1}')
IP2=$(docker exec machine-2 cat /etc/hosts | grep "machine-2" | awk '{print $1}')
IP3=$(docker exec machine-3 cat /etc/hosts | grep "machine-3" | awk '{print $1}')

ENDPOINTS=$IP1:2379,$IP2:2379,$IP3:2379

echo "endpoints : $ENDPOINTS"

etcdctl --endpoints=$ENDPOINTS member list -w table

echo -n "revision : "
etcdctl --endpoints=$ENDPOINTS get revisiontestkey -w json

CNT=0
while [ $CNT -lt 150 ]; do
    etcdctl --endpoints=$ENDPOINTS put key${CNT} value${CNT}
    CNT=$[$CNT + 1]
done

echo -n "revision : "
etcdctl --endpoints=$ENDPOINTS get revisiontestkey -w json
