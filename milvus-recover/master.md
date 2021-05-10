# master 模块断电恢复的设计文档

## 基本思路
1. master 启动时从 etcd 读取 meta 信息
2. master 每次消费 msgstream 时，需要将 msgstream 的position 存入 etcd
3. master 启动时从 etcd 读取 msgstream 的 position 值，然后 seek 到指定的 position，重新消费 msgstream
4. master 断电恢复后消费 msgstream 的消息，需要确保为幂等行文，重复消息的消费不会造成系统性能的不一致
5. 所有模块消费 msgstream 均为幂等行为，同一个消息可以被消费多次 

##
 
