#!/bin/bash
docker run --rm --network host -v /etc/localtime:/etc/localtime:ro pingcap/tikv:latest \
    --addr=0.0.0.0:20160 \
    --advertise-addr=127.0.0.1:20160 \
    --data-dir=/data/tikv0 \
    --pd=127.0.0.1:2379 \
    --log-file=/logs/tikv0.log
