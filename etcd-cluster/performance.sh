#!/bin/bash

function perf_test(){
echo "keyPrefix=$1,valPrefix=$2"
CLIENT=$HOME/work/gopath/src/golearn/exp/etcd_client_exp2

docker-compose down
docker-compose up -d
$CLIENT  -numQuery 10000 -mod 'put' -keyPrefix $1 -valPrefix $2 -numClient 1  -outCnt 1
docker-compose down

docker-compose up -d
$CLIENT  -numQuery 10000 -mod 'put' -keyPrefix $1 -valPrefix $2 -numClient 10  -outCnt 1
docker-compose down

docker-compose up -d
$CLIENT  -numQuery 10000 -mod 'put' -keyPrefix $1 -valPrefix $2 -numClient 100  -outCnt 1

$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 1  -outCnt 1
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 1  -outCnt 10
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 1  -outCnt 100
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 1  -outCnt 1000
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 1  -outCnt 10000

$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 10  -outCnt 1
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 10  -outCnt 10
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 10  -outCnt 100
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 10  -outCnt 1000
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 10  -outCnt 10000

$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 100  -outCnt 1
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 100  -outCnt 10
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 100  -outCnt 100
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 100  -outCnt 1000
$CLIENT  -numQuery 10000 -mod 'get' -keyPrefix $1 -numClient 100  -outCnt 10000
echo "+++++++++++++++++++++++++++"
}

echo "==========================================="

perf_test 0 8
perf_test 16 32
perf_test 32 64
perf_test 64 128
perf_test 128 256
perf_test 256 512
perf_test 512 1024

echo "==========================================="
