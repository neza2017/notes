#!/bin/bash
unset http_proxy
unset https_proxy

killall masterservice
killall proxyservice
killall dataservice
killall indexservice
killall queryservice
killall proxynode
killall datanode
killall indexnode
killall querynode