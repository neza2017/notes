# master 模块断电恢复的设计文档

## 基本思路
1. master 启动时从 etcd 读取 meta 信息
2. master 每次消费 msgstream 时，需要将 msgstream 的position 存入 etcd
3. master 启动时从 etcd 读取 msgstream 的 position 值，然后 seek 到指定的 position，重新消费 msgstream
4. master 断电恢复后消费 msgstream 的消息，需要确保为幂等行文，重复消息的消费不会造成系统性能的不一致
5. 所有模块消费 msgstream 均为幂等行为，同一个消息可以被消费多次 

## 具体工作

### 从 etcd 读 meta
1. master 启动时需要从 etcd 加载 meta， 这部分已经完成

### grpc 过来的请求
1. 从 grpc 过来的请求，以写入 etcd 作为最终标记，如果数据写入 etcd ，则表示操作成功，否则表示操作失败
2. grpc 的请求如果为 dd 类型，如 create_collection, create_partition 等，操作成功后需要将 dd 请求发送到 msgstream  的 dd channel
3. 这里可能存在一个故障，就是 grpc 过来的请求已经写入 etcd 了，但是还没发送到 dd channel，此时 master 奔溃了
4. 针对第 3 条提到的请求，master 在启动是需要检查所有 grpc 过来的 dd 请求，是否发送到 dd channel
5. master 内置的调度器 scheduler ，确保所有的 grpc 请求是串行执行的，那么只需要检查最近的 dd 请求是否发送到 dd channel，如果没有则重新发送
6. 已 create_collection 为例说明具体流程
    - create collection 的写入 etcd 时，额外更新 3 个 key，dd_msg, dd_type,dd_flag
    - dd_msg 为需要发送到 dd channel 的消息序列化
    - dd_type 为 dd_msg 的消息类型，如 create_collection, create_partition，drop_collection 等，用户反序列化 dd_msg
    - dd_flag 为 bool 类型变量，表示当前 dd_msg 是否已经发送 dd channel
    - create collection 在写入 etcd 时，同步更新这 3 个 key, 并且设置 dd_flag 为 false
    - 当 dd_msg 被发送到 dd channel 后，在更新 dd_flag
    - master 启动时，先检查 dd_flag 如果为 false，则将 根据 dd_type 将 dd_msg 发序列化，然后发送到 dd channel，否则不做任何处理
    - 这里可能存在一个故障，就是 dd_msg 已经发送到 dd channel，但是 dd_flag 还未更新，那么可能导致 dd_msg 被重复到送到 dd channel，所有需要接收端是幂等，消息可以重复消费 

### data service 过来的 new segment
1. 每次新建一个 segment 时， data service 将 segment id 通过 msgstream 发送到 master
2. master 需要将这个 segment id 更新到 collection meta


## data node 过来的 segment flush
1. data node 每次 flush 完成一个 segment 后，会将 segment id 通过 msgstream 发送 master
2. master需要根据 segment id 将 binlog 取出，然后向 index service 发送请求，在这个 segment 上创建索引
