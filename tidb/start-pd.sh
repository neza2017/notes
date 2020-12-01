#!/bin/bash

rm -rf /tmp/data/pd0
rm -rf /tmp/logs/pd0.log
$HOME/work/pd/bin/pd-server \
--name=pd0 \
--client-urls=http://0.0.0.0:2379 \
--peer-urls=http://0.0.0.0:2380 \
--advertise-client-urls=http://127.0.0.1:2379 \
--advertise-peer-urls=http://127.0.0.1:2380 \
--initial-cluster=pd0=http://127.0.0.1:2380 \
--data-dir=/tmp/data/pd0 \
--log-file=/tmp/logs/pd0.log
