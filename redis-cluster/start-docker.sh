#!/bin/bash

docker run -d -v $PWD/redis.conf:/usr/local/etc/redis/redis.conf  \
            -p 6379:6379  \
           --name redis redis:6.0.6   \
           redis-server /usr/local/etc/redis/redis.conf