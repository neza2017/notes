# master 模块断电恢复的设计文档

## 1. 基本思路
1. master 启动时从 etcd 读取 meta 信息
2. master 每次消费 msgstream 时，需要将 msgstream 的position 存入 etcd
3. master 启动时从 etcd 读取 msgstream 的 position 值，然后 seek 到指定的 position，重新消费 msgstream
4. master 断电恢复后消费 msgstream 的消息，需要确保为幂等行文，重复消息的消费不会造成系统性能的不一致
5. 所有模块消费 msgstream 均为幂等行为，同一个消息可以被消费多次 

## 2. 具体工作

### 2.1 从 etcd 读 meta
1. master 启动时需要从 etcd 加载 meta， 这部分已经完成

### 2.2 grpc 过来的 dd 请求
1. 从 grpc 过来的请求，以写入 etcd 作为最终标记，如果数据写入 etcd ，则表示操作成功，否则表示操作失败
2. grpc 的请求如果为 dd 类型，如 create_collection, create_partition 等，操作成功后需要将 dd 请求发送到 msgstream  的 dd channel
3. 这里可能存在一个故障，就是 grpc 过来的请求已经写入 etcd 了，但是还没发送到 dd channel，此时 master 奔溃了
4. 针对第 3 条提到的请求，master 在启动是需要检查所有 grpc 过来的 dd 请求，是否发送到 dd channel
5. master 内置的调度器 scheduler ，确保所有的 grpc 请求是串行执行的，那么只需要检查最近的 dd 请求是否发送到 dd channel，如果没有则重新发送
6. 以 create_collection 为例说明具体流程
    - create collection 的写入 etcd 时，额外更新 3 个 key，dd_msg, dd_type,dd_flag
    - dd_msg 为需要发送到 dd channel 的消息序列化
    - dd_type 为 dd_msg 的消息类型，如 create_collection, create_partition，drop_collection 等，用户反序列化 dd_msg
    - dd_flag 为 bool 类型变量，表示当前 dd_msg 是否已经发送 dd channel
    - create collection 在写入 etcd 时，同步更新这 3 个 key, 并且设置 dd_flag 为 false
    - 当 dd_msg 被发送到 dd channel 后，在更新 dd_flag
    - master 启动时，先检查 dd_flag 如果为 false，则将 根据 dd_type 将 dd_msg 发序列化，然后发送到 dd channel，否则不做任何处理
    - 这里可能存在一个故障，就是 dd_msg 已经发送到 dd channel，但是 dd_flag 还未更新，那么可能导致 dd_msg 被重复到送到 dd channel，所有需要接收端是幂等，消息可以重复消费 

### 2.3 grpc 过来的 create index 请求
1. grpc 过来的 create index 请求，回到用 meta 的 GetNotIndexedSegments 方法获得没有建立索引的所有 segment id
2. 获得这些没有建立索引的 segment id 后，依次调用 index service 的服务创建索引
3. 在当前的实现中，只是把 这些 segment id 放入一个  go channel ,就向 grpc 返回了
4. master service 内启动一个后台任务，不断从 go channel 内去读取这些 segment id，然后调用 index service 的服务去创建索引
5. 那么这里存在一个故障，在 grpc 请求的处理函数中已经把这些 segment id 放入 go channel 内，然后 grpc 返回了，但是 master service 的后台服务还未从 go channel 中读取，此时 master 奔溃了,此时客户端以为创建了索引，但是实际 master 并为向 index service 发送创建索引的服务
6. 修改方案如下：
    - 去掉当前实现中的 go channel 以及 master service 的后台服务
    - 在 grpc 的请求处理函数中，只有当所有的 segment id 均向 index service 发送创建索引的请求后，才返回当前的 grpc 请求
    - 根据幂等原则，如果有部分 segment id 向 index service 发送请求，此时 master 奔溃，此时客户端收到的请求是 create index 失败，等 master 重启后，会再次发送 create index 请求
    - 那么可能存在 部分 segment id 重复创建索引，index service 需要处理这种请求  


### 2.4 data service 过来的 new segment
1. 每次新建一个 segment 时， data service 将 segment id 通过 msgstream 发送到 master
2. master 需要将这个 segment id 更新到 collection meta，同时在 etcd 中记该 msgstream 的 position
3. 步骤 2 是事务的并且只有更新了 etcd 中的 collection meta 才算操作成功
4. 那么在 etcd 中记录的 segment id 的 position，一定已经被更新到 collection meta 中，所以master 断电恢复时只需要将 msgstream 恢复到 position 的位置即可


### 2.5 data node 过来的 segment flush
1. data node 每次 flush 完成一个 segment 后，会将 segment id 通过 msgstream 发送 master
2. master需要根据 segment id 将 binlog 取出，然后向 index service 发送请求，在这个 segment 上创建索引
3. 调用 index service 成功后，会返回一个 build id，然后 master 会将改 build id 更新到 meta中，同时在 etcd 中记录该 msgstream 的 position
4. 步骤 3 是事务的并且只有更新了 etcd 中的 collection meta 才算操作成功
5. 那么在 etcd 中记录的 segment id 的 position，一定已经被更新到 collection meta 中，所以master 断电恢复时只需要将 msgstream 恢复到 position 的位置即可
6. 因为 2.4 小节和 2.5 小节共用同一个 msgstream 的输入，但是当前实现中这两部分在不同的后台任务中实现，那么可能存在一个故障，就是这两个后台任务中先读取 msgstream 的后更新 position，那么会导致 msgstream 恢复到错误位置
7. 这里需要修改， 2.4 和 2.5 小节的工作在同一个后台任务中处理 

### 2.6 调用外部 grpc 服务失败
1. segment flush 完成后，需要 master 从 data service 获取 binlog path ，然后向 index service 发送请求，此处需要和 data service 以及 index service 存在 grpc 交互，如果 grpc 失败，则直接重连
