# master 对外接口整理

```go
type ModuleInterface interface {
  Init() error;
  Start() error;
  Stop() error;
}
```

```go
type MasterModuleInterface interface {
  ModuleInterface
  GetMasterStats() (MasterStatus, error)
}
```
这里需要定义 **MasterStatus** 的 `proto`



```go
type Master interface {
  //DDL request
  CreateCollection(ctx context.Context, in *internalpb.CreateCollectionRequest) (*commonpb.Status, error)
  DropCollection(ctx context.Context, in *internalpb.DropCollectionRequest) (*commonpb.Status, error) 
  HasCollection(ctx context.Context, in *internalpb.HasCollectionRequest) (*servicepb.BoolResponse, error)
  DescribeCollection(ctx context.Context, in *internalpb.DescribeCollectionRequest) (*servicepb.CollectionDescription, error)
  ShowCollections(ctx context.Context, in *internalpb.ShowCollectionRequest) (*servicepb.StringListResponse, error)
  CreatePartition(ctx context.Context, in *internalpb.CreatePartitionRequest) (*commonpb.Status, error)
  DropPartition(ctx context.Context, in *internalpb.DropPartitionRequest) (*commonpb.Status, error)
  HasPartition(ctx context.Context, in *internalpb.HasPartitionRequest) (*servicepb.BoolResponse, error)
  DescribePartition(ctx context.Context, in *internalpb.DescribePartitionRequest) (*servicepb.PartitionDescription, error)
  ShowPartitions(ctx context.Context, in *internalpb.ShowPartitionRequest) (*servicepb.StringListResponse, error)

  //直接调用 `Index builder` 的服务
  CreateIndex(ctx context.Context, req *internalpb.CreateIndexRequest) (*commonpb.Status, error)

  //global timestamp allocator
  AllocTimestamp(ctx context.Context, request *internalpb.TsoRequest) (*internalpb.TsoResponse, error)
  AllocID(ctx context.Context, request *internalpb.IDRequest) (*internalpb.IDResponse, error)

  //从 proxyservice 接收 timetick 消息，转发到 master 的 timetick channel
  GetTimeTickChannel() (string, error)

  //接收 ddl request，并将请求转发到 dd channel；从 proxyservice 接收 timetick 消息，也转发到 dd channel
  GetDdChannel() (string, error)

  //master 定时调用 `GetMasterStats`,并将消息放入到这个 channel
  GetStatsChannel() (string, error)

  //获得系统配置信息，暂时未使用
  GetSysConfigs(ctx context.Context, in *internalpb.SysConfigRequest)
}
```

与 `Data Service` 的 rpc 通信
```go
type DataService interface{
  GetSegmentStats(segmentID) (segmentStats, error)
  GetBinlogFilePath(segmentID) (binlogFilePath,error)
}
```
`Data Service`的 grpc 及 `proto` 未定义

既然 `meta`已经由 `Data Node` 存入 `etcd`，那么 `master`直接查询 `etcd` 不是更方便吗，为啥需要通过 `Data Service` 之间的 RPC 通信?

需要明确一点 `Flush` 指令是 `proxy service` 直接发送给 `data service`，那么 `proxy service` 与 `data service` 之间需要有 `rpc` 链接?



与 `IndexBuilder` 的 rpc 通信
`master` 与 `IndexBuilder` 间的 rpc 通信，是通过 之前定义的 `client` 还是 master 直接 `rpc` 与 `IndexBuilder` 链接
同样道理，`DataService` 的 rpc 提供 `client` 吗？ 还是直接上链接 rpc


`DataNode` 完成 `Flush`操作后，会将 `segment id` 放入 `channel`，同时 `DataNode` 会更新 `etcd`中的 `meta` 记录 当前 `segment id` 包含该哪些 `binlog file path`



