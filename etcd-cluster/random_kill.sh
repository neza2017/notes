#!/bin/bash
cnt=1
while [ $cnt -gt 0 ]; do
    idx=$[$RANDOM%3]
    idx=$[$idx+1]
    etch_server="machine-${idx}"
    echo "$cnt: stop docker $etch_server"

    docker stop $etch_server
    sleep 1
    docker start $etch_server
    sleep 1

    cnt=$[$cnt+1]
done
