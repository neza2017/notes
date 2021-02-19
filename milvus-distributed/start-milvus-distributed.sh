#!/bin/bash
unset http_proxy
unset https_proxy

pushd ~/work/milvus-distributed/deployments/docker
docker-compose down
docker-compose up -d
popd

pushd ~/work/milvus-distributed
echo "start master service"
./bin/masterservice > /tmp/masterservice.log  2>&1  &
sleep 1
echo "start service"
./bin/proxyservice > /tmp/proxyservice.log  2>&1  &
./bin/dataservice > /tmp/dataservice.log  2>&1  &
./bin/indexservice > /tmp/indexservice.log  2>&1  &
./bin/queryservice > /tmp/queryservice.log  2>&1  &
sleep 5
echo "start node"
./bin/proxynode > /tmp/proxynode.log  2>&1  &
./bin/datanode > /tmp/datanode.log  2>&1  &
./bin/indexnode > /tmp/indexnode.log  2>&1  &
./bin/querynode > /tmp/querynode.log  2>&1  &