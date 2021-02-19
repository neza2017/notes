#!/bin/bash
unset http_proxy
unset https_proxy

ps ax | grep -e masterservice -e proxyservice -e dataservice -e indexservice -e queryservice -e proxynode -e datanode -e indexnode -e querynode
ps ax | grep -e masterservice -e proxyservice -e dataservice -e indexservice -e queryservice -e proxynode -e datanode -e indexnode -e querynode | wc -l
