```go
type MasterClient interface {
  CreateCollection(req CreateCollectionRequest) error
  DropCollection(req DropCollectionRequest) error
  HasCollection(req HasCollectionRequest) (bool, error)
  DescribeCollection(req DescribeCollectionRequest) (CollectionDescription, error)
  ShowCollections(req ShowCollectionRequest) ([]string, error)
  CreatePartition(req CreatePartitionRequest) error
  DropPartition(req DropPartitionRequest) error
  HasPartition(req HasPartitionRequest) (bool, error)
  DescribePartition(req DescribePartitionRequest) (PartitionDescription, error)
  ShowPartitions(req ShowPartitionRequest) ([]string, error)
  AllocTimestamp(req TsoRequest) (TsoResponse, error)
  AllocID(req IDRequest) (IDResponse, error)
  GetDdChannel() (string, error)
  GetTimeTickChannel() (string, error)
  GetStatsChannel() (string, error)
}
```

```go
type Service interface {
    Init() error;
    Start() error;
    Stop() error;
    Desc() error;
}

func NewMasterService() (Service, error)
```

需要明确几个事情
- 1.`GetDdChannel`，`GetTimeTickChannel`和`GetStatsChannel`这些 channel 分别是干什么的，直接通过 `API` 调用不就可以了吗?
- 2.`Master`原先的`GetSysConfigs`是否需要保留
