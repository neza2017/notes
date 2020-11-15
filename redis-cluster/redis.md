# redis 集群测试

## docker-compose

redis 集群要求至少有 3 个 master 节点，另外如果实现 master-slave 的主备复制，至少需要 3 个 slave 节点，那么 redis 集群至少需要 6 个节点, 另外 redis 集群只能使用 ip，不能使用域名

```yml
version: '3.5'
services:
    redis-1:
        image: redis:6.0.6
        hostname: redis-1
        container_name: redis-1
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10001:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.101

    redis-2:
        image: redis:6.0.6
        hostname: redis-2
        container_name: redis-2
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10002:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.102

    redis-3:
        image: redis:6.0.6
        hostname: redis-3
        container_name: redis-3
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10003:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.103

    redis-4:
        image: redis:6.0.6
        hostname: redis-4
        container_name: redis-4
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10004:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.104
    
    redis-5:
        image: redis:6.0.6
        hostname: redis-5
        container_name: redis-5
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10005:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.105

    redis-6:
        image: redis:6.0.6
        hostname: redis-6
        container_name: redis-6
        command: redis-server /usr/local/etc/redis/redis.conf
        ports:
            - 10006:6379
        volumes:
            - /tmp/redis.conf:/usr/local/etc/redis/redis.conf
        networks:
            redis-net:
                ipv4_address: 172.20.0.106

networks:
    redis-net:
        name: redis-net
        driver: bridge
        ipam:
            config:
                - subnet: 172.20.0.0/24
```

## 启动 redis 集群

### 复制 `redis.conf` 

因为在 `docker-compose` 中 `redis.conf` 的映射路径为 `/tmp/redis.conf`
```bash
cp redis.conf /tmp/
```

### 启动 docker-compose
```bash
docker-compose up -d
```

### 观察 `redis` 的输出日志
```bash
$ docker logs -f redis-4
1:C 29 Jul 2020 10:19:39.810 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
1:C 29 Jul 2020 10:19:39.810 # Redis version=6.0.6, bits=64, commit=00000000, modified=0, pid=1, just started
1:C 29 Jul 2020 10:19:39.810 # Configuration loaded
1:M 29 Jul 2020 10:19:39.811 * No cluster configuration found, I'm d05d9293e52ec32c6a74e0038ec789e0212986e2
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 6.0.6 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in cluster mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 1
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

1:M 29 Jul 2020 10:19:39.817 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
1:M 29 Jul 2020 10:19:39.817 # Server initialized
1:M 29 Jul 2020 10:19:39.817 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 29 Jul 2020 10:19:39.817 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
1:M 29 Jul 2020 10:19:39.817 * Ready to accept connections
```

### 进入 `redis-1`
```bash
$ docker exec -it redis-1 bash
root@redis-1:/data# 
```

### 创建 `redis cluster` 
```bash
root@redis-1:/data# redis-cli --cluster create 172.20.0.101:6379 172.20.0.102:6379 172.20.0.103:6379 172.20.0.104:6379 172.20.0.105:6379 172.20.0.106:6379 --cluster-replicas 1
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 172.20.0.105:6379 to 172.20.0.101:6379
Adding replica 172.20.0.106:6379 to 172.20.0.102:6379
Adding replica 172.20.0.104:6379 to 172.20.0.103:6379
M: 74367119af339cecd23cd1f3a08d1d9838c83667 172.20.0.101:6379
   slots:[0-5460] (5461 slots) master
M: 4b040f61ea42f0d12d7522573666c3a7bbbf7d17 172.20.0.102:6379
   slots:[5461-10922] (5462 slots) master
M: 684531a34572159ae32942747c64443959fb9c58 172.20.0.103:6379
   slots:[10923-16383] (5461 slots) master
S: d05d9293e52ec32c6a74e0038ec789e0212986e2 172.20.0.104:6379
   replicates 684531a34572159ae32942747c64443959fb9c58
S: 071c3508b1247cedef92ff4d62f172b5605db6dd 172.20.0.105:6379
   replicates 74367119af339cecd23cd1f3a08d1d9838c83667
S: 1268e3ed10d4c094fc7b79c6e88e6109224aceae 172.20.0.106:6379
   replicates 4b040f61ea42f0d12d7522573666c3a7bbbf7d17
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join

>>> Performing Cluster Check (using node 172.20.0.101:6379)
M: 74367119af339cecd23cd1f3a08d1d9838c83667 172.20.0.101:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: d05d9293e52ec32c6a74e0038ec789e0212986e2 172.20.0.104:6379
   slots: (0 slots) slave
   replicates 684531a34572159ae32942747c64443959fb9c58
S: 071c3508b1247cedef92ff4d62f172b5605db6dd 172.20.0.105:6379
   slots: (0 slots) slave
   replicates 74367119af339cecd23cd1f3a08d1d9838c83667
M: 684531a34572159ae32942747c64443959fb9c58 172.20.0.103:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 1268e3ed10d4c094fc7b79c6e88e6109224aceae 172.20.0.106:6379
   slots: (0 slots) slave
   replicates 4b040f61ea42f0d12d7522573666c3a7bbbf7d17
M: 4b040f61ea42f0d12d7522573666c3a7bbbf7d17 172.20.0.102:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

### 观察集群状态
```bash
$ redis-cli -p 10001 cluster nodes
d05d9293e52ec32c6a74e0038ec789e0212986e2 172.20.0.104:6379@16379 slave 684531a34572159ae32942747c64443959fb9c58 0 1596018371000 3 connected
071c3508b1247cedef92ff4d62f172b5605db6dd 172.20.0.105:6379@16379 slave 74367119af339cecd23cd1f3a08d1d9838c83667 0 1596018372926 1 connected
684531a34572159ae32942747c64443959fb9c58 172.20.0.103:6379@16379 master - 0 1596018372000 3 connected 10923-16383
1268e3ed10d4c094fc7b79c6e88e6109224aceae 172.20.0.106:6379@16379 slave 4b040f61ea42f0d12d7522573666c3a7bbbf7d17 0 1596018373929 2 connected
4b040f61ea42f0d12d7522573666c3a7bbbf7d17 172.20.0.102:6379@16379 master - 0 1596018371000 2 connected 5461-10922
74367119af339cecd23cd1f3a08d1d9838c83667 172.20.0.101:6379@16379 myself,master - 0 1596018371000 1 connected 0-5460
```

## 数据插入测试
因为 redis-1 的 6379 端口映射到 10001 端口，所以可直接在 host 上链接 redis-1
```bash
$ redis-cli -c  -p 10001 
127.0.0.1:10001> set x 100
-> Redirected to slot [16287] located at 172.20.0.103:6379
OK
172.20.0.103:6379> set y 200
OK
172.20.0.103:6379> set z 300
-> Redirected to slot [8157] located at 172.20.0.102:6379
OK
172.20.0.102:6379> get x
-> Redirected to slot [16287] located at 172.20.0.103:6379
"100"
172.20.0.103:6379> get y
"200"
172.20.0.103:6379> get z
-> Redirected to slot [8157] located at 172.20.0.102:6379
"300"
172.20.0.102:6379>
```
redis 对 key 计算 hash 值，如果 key 不在当前机器上，自动转发到对应的机器上，取数据操作也一样，如果数据不在当前节点上，自动从对应的节点上取

## 注意事项
- redis 并不是强一致性的，可能存在数据丢失


参考文献
- https://redis.io/topics/quickstart
- https://redislabs.com/blog/getting-started-redis-6-access-control-lists-acls/
- https://redis.io/topics/cluster-tutorial
