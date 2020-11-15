#!/bin/bash

if [ $# -ne 1 ];then
        echo "usage : go-path: <go-path>"
        exit 0
fi

if [ ! -z $GOPATH ];then
        echo "origin GOPATH = ${GOPATH}"
        echo "origin PATH = ${PATH}"
        go_bin_path=:${GOPATH}/bin
        if [[ $PATH == *${go_bin_path}* ]];then
                PATH=${PATH/${go_bin_path}}
        fi
fi

export GOPATH=$1
if [[ $PATH != *${GOPATH}* ]];then
        export PATH=$PATH:$GOPATH/bin
fi

echo "GOPATH = ${GOPATH}"
echo "PATH = ${PATH}"

export http_proxy="http://127.0.0.1:8123"
export https_proxy="http://127.0.0.1:8123"
