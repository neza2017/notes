# etcd performance test
`etcd` 性能测试

## 启动 etcd
```bash
docker-compose up -d
```
启动 3 个 `docker` 容器， 组成 `etcd` 集群

## 测试机器配置
配置项目 | 值
---|---
操作系统 | ubuntu 16.04
内存 | 64G
CPU | Intel(R) Core(TM) i7-8700 CPU @ 3.20GHz
CPU核心数 | 12

## 插入性能测试
- keyPrefix = 0
- valPrefix = 0

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 36.350464893s | 0.0036350464893
10 | 10000 | 2m58.825411099s | 0.00178825411099
100 | 10000 | 7m14.464713808s | 0.000434464713808
---

- keyPrefix = 0
- valPrefix = 8

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 38.673408563s | 0.0038673408563
10 | 10000 | 3m0.495398664s | 0.00180495398664
100 | 10000 | 7m23.257567943s | 0.000443257567943
---

- keyPrefix = 16
- valPrefix = 32

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 41.227033717s | 0.0041227033717
10 | 10000 | 3m25.054593371s | 0.00205054593371
100 | 10000 | 8m11.64118346s | 0.00049164118346
---

- keyPrefix = 32
- valPrefix = 64

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 42.257080961s | 0.0042257080961
10 | 10000 | 3m26.365226497s | 0.00206365226497
100 | 10000 | 8m45.462138886s | 0.000525462138886
---

- keyPrefix = 64
- valPrefix = 128

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 42.357660353s | 0.0042357660353
10 | 10000 | 4m1.183889939s | 0.00241183889939
100 | 10000 | 9m12.600971888s | 0.000552600971888
---

- keyPrefix = 128
- valPrefix = 256

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 45.405267004s | 0.0045405267004
10 | 10000 | 4m53.77027441s | 0.0029377027441
100 | 10000 | 9m49.742762158s | 0.000589742762158
---

- keyPrefix = 256
- valPrefix = 512

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 51.29196651s | 0.005129196651
10 | 10000 | 5m47.140885938s | 0.00347140885938
100 | 10000 | 10m14.631966809s | 0.000614631966809
---

- keyPrefix = 512
- valPrefix = 1024

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 57.039198494s | 0.0057039198494
10 | 10000 | 7m1.917019642s | 0.00421917019642
100 | 10000 | 11m35.419813057s | 0.000695419813057
---

- keyPrefix = 1024
- valPrefix = 2048

numClient | numQuery | Cost | Cost/(numClient*numQuery)
---|---|---|---
1 | 10000 | 1m25.131833269s | 0.0085131833269
10 | 10000 | 8m17.290917676s | 0.00497290917676


numClient | numQuery | Cost 
---|---|---
100 | 10000 | etcdserver: mvcc: database space exceeded，实际插入 522082 行



## 查询性能测试

- keyPrefix = 0
- valPrefix = 0
- totalRecord = 1000000

numClient | numQuery | outCnt |  Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 4.510157225s | 0.0004510157225
1  | 10000 | 10 |6.124742179s | 0.0006124742179
1  | 10000 | 100 | 8.22231179s | 0.000822231179
1  | 10000 | 1000 | 41.041749023s | 0.0041041749023
1  | 10000 | 10000 |  4m0.329169487s | 0.0240329169487
10 | 10000 | 1 | 10.077377851s | 0.00010077377851
10 | 10000 | 10 | 12.691186134s | 0.00012691186134
10 | 10000 | 100 | 17.616168384s | 0.00017616168384
10 | 10000 | 1000 | 1m15.664146725s | 0.00075664146725
10 | 10000 | 10000 | 10m44.779203112s | 0.00644779203112
100 | 10000 | 1 | 50.633396754s | 0.000050633396754 
100 | 10000 | 10 |1m8.959196829s | 0.000068959196829
100 | 10000 | 100 | 2m4.499225078s | 0.000124499225078
100 | 10000 | 1000 | 11m40.569337932s | 0.000700569337932
100 | 10000 | 10000 | 1h37m2.6588128s | 0.00582265881280000057


### 异常查询
- numClient 1000
- numQuery 10000
- outCnt 1

返回结果：
- 在台式机器 只有341个client完成查询，具体原因待查
- 在服务器测试,(48核，512G内存)，也只有 343 个查询返回结果，具体原因待查

解决方案:
排查日志发现 `file descriptor` 达到上限制，导致系统没有返回，该值默认为 `1024`，将其改为 `65536` 即可
```
ulimit -n 65536
```

---

- keyPrefix = 0
- valPrefix = 8
- totalRecord = 1000000

numClient | numQuery | outCnt |  Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.060234997s | 0.0005060234997
1  | 10000 | 10 | 5.090872414s | 0.0005090872414
1  | 10000 | 100 | 7.530374023s | 0.0007530374023
1  | 10000 | 1000 | 39.574146703s | 0.0039574146703
1  | 10000 | 10000 | 3m59.531326547s | 0.0119531326547
10 | 10000 | 1 | 11.417788765s | 0.00011417788765
10 | 10000 | 10 | 12.162896801s | 0.00012162896801
10 | 10000 | 100 | 18.370339671s | 0.00018370339671
10 | 10000 | 1000 | 1m18.927374417s | 0.00078927374417
10 | 10000 | 10000 | 11m47.835531938s | 0.00707835531938
100 | 10000 | 1 | 1m6.585280496s | 0.000066585280496
100 | 10000 | 10 | 1m12.481631438s | 0.000072481631438
100 | 10000 | 100 | 2m12.710319577s | 0.000132710319577
100 | 10000 | 1000 | 12m0.747062255s | 0.000720747062255
100 | 10000 | 10000 | 1h40m27.392987505s | 0.006027392987505
1000 | 10000 | 1 | --
---

- keyPrefix = 16
- valPrefix = 32
- totalRecord = 1000000

numClient | numQuery | outCnt |  Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.112197134s | 0.0005112197134
1  | 10000 | 10 | 5.038221093s | 0.0005038221093
1  | 10000 | 100 | 7.773552577s | 0.0007773552577
1  | 10000 | 1000 | 40.520117129s | 0.0040520117129
1  | 10000 | 10000 | 4m9.053849894s | 0.0249053849894
10 | 10000 | 1 | 11.346867522s | 0.00011346867522
10 | 10000 | 10 | 12.233665817s | 0.00012233665817
10 | 10000 | 100 | 18.942400783s | 0.00018942400783
10 | 10000 | 1000 | 1m24.556845666s | 0.00084556845666
10 | 10000 | 10000 | 11m48.427247481s | 0.00708427247481
100 | 10000 | 1 | 1m4.237075574s | 0.000064237075574
100 | 10000 | 10 | 1m10.609761133s | 0.000070609761133
100 | 10000 | 100 | 2m18.405527375s | 0.000138405527375
100 | 10000 | 1000 | 12m53.863637552s |0.000773863637552 
100 | 10000 | 10000 | 1h47m9.687592253s | 0.006429687592253
1000 | 10000 | 1 | --
---

- keyPrefix = 32
- valPrefix = 64
- totalRecord = 1000000

numClient | numQuery | outCnt |  Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.330448005s | 0.0005330448005
1  | 10000 | 10 | 5.215401612s | 0.0005215401612
1  | 10000 | 100 | 7.829740924s | 0.0007829740924
1  | 10000 | 1000 | 40.912820883s | 0.0040912820883
1  | 10000 | 10000 | 4m18.010962284s | 0.0258010962284
10 | 10000 | 1 | 11.097586512s | 0.00011097586512
10 | 10000 | 10 | 12.091558657s | 0.00012091558657
10 | 10000 | 100 | 19.624895579s | 0.00019624895579
10 | 10000 | 1000 | 1m28.937673275s | 0.00088937673275
10 | 10000 | 10000 | 12m39.45924949s | 0.0075945924949
100 | 10000 | 1 | 1m0.192233992s | 0.000060192233992
100 | 10000 | 10 | 1m10.693772307s | 0.000070693772307
100 | 10000 | 100 | 2m22.696050776s | 0.000142696050776
100 | 10000 | 1000 | 13m36.224320085s | 0.000816224320085
100 | 10000 | 10000 | 1h54m22.3596029s | 0.0068623596029
1000 | 10000 | 1 | --
---

- keyPrefix = 64
- valPrefix = 128
- totalRecord = 1000000

numClient | numQuery | outCnt | Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.19982998s | 0.000519982998
1  | 10000 | 10 | 5.213901833s | 0.0005213901833
1  | 10000 | 100 | 8.368434548s | 0.0008368434548
1  | 10000 | 1000 | 43.117577646s | 0.0043117577646
1  | 10000 | 10000 | 4m42.260314239s | 0.0282260314239
10 | 10000 | 1 | 11.092017388s | 0.00011092017388
10 | 10000 | 10 | 12.327903328s | 0.00012327903328
10 | 10000 | 100 | 21.21349275s | 0.0002121349275
10 | 10000 | 1000 | 1m43.206036833s | 0.00103206036833
10 | 10000 | 10000 | 14m26.993365876s | 0.00866993365876
100 | 10000 | 1 | 1m1.266352078s | 0.000061266352078
100 | 10000 | 10 | 1m13.312008179s | 0.000073312008179
100 | 10000 | 100 | 2m37.468973011s | 0.000157468973011
100 | 10000 | 1000 | 15m17.839575831s | 0.000917839575831
100 | 10000 | 10000 | 2h12m23.914183486s | 0.007943914183486
1000 | 10000 | 1 |--
---

- keyPrefix = 128
- valPrefix = 256
- totalRecord = 1000000

numClient | numQuery | outCnt| Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.366540477s | 0.0005366540477
1  | 10000 | 10 | 5.379198661s | 0.0005379198661
1  | 10000 | 100 | 8.86255403s | 0.000886255403
1  | 10000 | 1000 | 41.607026714s | 0.0041607026714
1  | 10000 | 10000 | 5m23.294016818s | 0.0323294016818
10 | 10000 | 1 | 10.681439567s | 0.00010681439567
10 | 10000 | 10 | 12.152953191s | 0.00012152953191
10 | 10000 | 100 | 23.319602042s | 0.00023319602042
10 | 10000 | 1000 | 2m5.702977564s | 0.00125702977564
10 | 10000 | 10000 | 18m28.386151859s | 0.01108386151859
100 | 10000 | 1 | 56.501915482s | 0.000056501915482
100 | 10000 | 10 | 1m10.580107305s | 0.000070580107305
100 | 10000 | 100 | 2m55.996389884s | 0.000175996389884
100 | 10000 | 1000 | 18m39.198393405s | 0.001119198393405
100 | 10000 | 10000 | 2h48m40.2648679s | 0.0101202648679
1000 | 10000 | --
---

- keyPrefix = 256
- valPrefix = 512
- totalRecord = 1000000

numClient | numQuery | outCnt | Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.339173225s | 0.000533917322
1  | 10000 | 10 | 5.79225601s | 0.000579225601
1  | 10000 | 100 | 10.013675825s | 0.0010013675825
1  | 10000 | 1000 | 50.302076928s | 0.0050302076928
1  | 10000 | 10000 | 6m51.901978326s | 0.0411901978326
10 | 10000 | 1 | 10.441078271s | 0.00010441078271
10 | 10000 | 10 | 12.791443846s | 0.00012791443846
10 | 10000 | 100 | 27.119823211s | 0.00027119823211
10 | 10000 | 1000 | 2m59.99255424s | 0.0017999255424
10 | 10000 | 10000 | 26m33.86955603s | 0.0159386955603
100 | 10000 | 1 | 53.456193683s | 0.000053456193683
100 | 10000 | 10 | 1m13.655362924s | 0.000073655362924
100 | 10000 | 100 | 3m31.846118629s | 0.000211846118629
100 | 10000 | 1000 | 25m55.748737917s | 0.001555748737917
100 | 10000 | 10000 | 4h3m47.272590773s | 0.014627272590773
1000 | 10000 | 1 |--
---

- keyPrefix = 512
- valPrefix = 1024
- totalRecord = 1000000

numClient | numQuery | outCnt | Cost | Cost/(numClient*numQuery)
---|---|---|---|---
1  | 10000 | 1 | 5.224902098s | 0.0005224902098
1  | 10000 | 10 | 5.942065845s | 0.0005942065845
1  | 10000 | 100 | 12.063014154s | 0.0012063014154
1  | 10000 | 1000 | 1m4.757801938s | 0.0064757801938
1  | 10000 | 10000 | 9m30.27797742s | 0.057027797742
10 | 10000 | 1 | 10.275107408s | 0.00010275107408
10 | 10000 | 10 | 13.002071418s | 0.00013002071418
10 | 10000 | 100 | 33.930730274s | 0.00033930730274
10 | 10000 | 1000 | 4m30.53601569s | 0.0027053601569
10 | 10000 | 10000 | 41m9.626208971s | 0.02469626208971
100 | 10000 | 1 | 52.704614361s | 0.000052704614361
100 | 10000 | 10 | 1m21.31299533s | 0.00008131299533
100 | 10000 | 100 | 4m48.649234065s | 0.000288649234065
100 | 10000 | 1000 | 41m14.953949382s | 0.002474953949382
100 | 10000 | 10000 | 6h26m8.57758543s | 0.02316857758543
1000 | 10000 | 1 |--
---



## 测试代码
```go
package main

import (
	"context"
	"flag"
	"fmt"
	"go.etcd.io/etcd/clientv3"
	"log"
	"math/rand"
	"time"
)

const (
	totalRecords = 1000000
)

func getOp(numClient int, numQuery int, keyPrefix int, outCnt int, endpoints []string) {

	if (outCnt != 1) && (outCnt != 10) && (outCnt != 100) && (outCnt != 1000) && (outCnt != 10000) {
		log.Fatal("output count should be 10,100,1000,10000")
	}

	ch := make(chan int)
	log.Printf("get, numClient = %d, numQuery=%d, keyPrefix=%d, outCnt=%d\n", numClient, numQuery, keyPrefix, outCnt)
	clients := make([]*clientv3.Client, numClient)
	defer func() {
		for i := 0; i < numClient; i++ {
			if clients[i] != nil {
				clients[i].Close()
			}
		}
	}()

	prefix := ""
	for i := 0; i < keyPrefix; i++ {
		prefix += "0"
	}

	for i := 0; i < numClient; i++ {
		cli, err := clientv3.New(clientv3.Config{
			Endpoints: endpoints,
		})
		if err != nil {
			log.Fatal(err)
		}
		clients[i] = cli
	}
	start := time.Now()
	for i := 0; i < numClient; i++ {
		i := i
		cli := clients[i]
		if outCnt == 1 {
			go func() {
				//log.Printf("start client %d\n", i)
				for j := 0; j < numQuery; j++ {
					key := fmt.Sprintf("%skey%d", prefix, rand.Int()%totalRecords)
					if _, err := cli.Get(context.TODO(), key); err != nil {
						log.Fatal(err)
					}
				}
				ch <- 0
				//log.Printf("finish client %d\n", i)
			}()
		} else {
			go func() {
				//log.Printf("start client %d\n", i)
				rngBegin := totalRecords / (outCnt * 10)
				rngEnd := totalRecords / outCnt
				rngRange := rngEnd - rngBegin
				expCnt := ((outCnt - 1) / 9) + outCnt
				for j := 0; j < numQuery; j++ {
					rnd := rand.Int() % rngRange
					rnd += rngBegin
					key := fmt.Sprintf("%skey%d", prefix, rnd)
					if rsp, err := cli.Get(context.TODO(), key, clientv3.WithPrefix()); err != nil || rsp.Count != int64(expCnt) {
						if err != nil {
							log.Fatal(err)
						} else {
							log.Fatalf("output count = %d, expect output = %d\n", rsp.Count, expCnt)
						}
					}
				}
				ch <- 0
				//log.Printf("finish client %d\n", i)
			}()
		}
	}
	for i := 0; i < numClient; i++ {
		<-ch
	}
	end := time.Now()
	span := end.Sub(start)
	log.Printf("end query, cost %v\n", span)
}

func putOp(numClient int, numQuery int, keyPrefix int, valPrefix int, endpoints []string) {
	ch := make(chan int)
	log.Printf("put, numClient = %d, numQuery=%d, keyPrefix=%d, valPrefix=%d\n", numClient, numQuery, keyPrefix, valPrefix)
	clients := make([]*clientv3.Client, numClient)
	defer func() {
		for i := 0; i < numClient; i++ {
			if clients[i] != nil {
				clients[i].Close()
			}
		}
	}()

	preKey := ""
	for i := 0; i < keyPrefix; i++ {
		preKey += "0"
	}
	preVal := ""
	for i := 0; i < valPrefix; i++ {
		preVal += "0"
	}

	for i := 0; i < numClient; i++ {
		cli, err := clientv3.New(clientv3.Config{
			Endpoints: endpoints,
		})
		if err != nil {
			log.Fatal(err)
		}
		clients[i] = cli
	}

	start := time.Now()
	for i := 0; i < numClient; i++ {
		i := i
		cli := clients[i]
		go func() {
			for j := 0; j < numQuery; j++ {
				key := fmt.Sprintf("%skey%d", preKey, i*numQuery+j)
				val := fmt.Sprintf("%svalue%d", preVal, i*numQuery+j)
				if _, err := cli.Put(context.TODO(), key, val); err != nil {
					log.Fatal(err)
				}
			}
			ch <- 0
		}()
	}

	for i := 0; i < numClient; i++ {
		<-ch
	}
	end := time.Now()
	span := end.Sub(start)
	log.Printf("end query, cost %v\n", span)
}

func main() {
	numClient := flag.Int("numClient", 1000, "num of client")
	numQuery := flag.Int("numQuery", 1000, "num of query per client")
	mod := flag.String("mod", "get", "put/get")
	keyPrefix := flag.Int("keyPrefix", 0, "size of key prefix")
	valPrefix := flag.Int("valPrefix", 0, "size of value prefix")
	outCnt := flag.Int("outCnt", 1, "output count 10, 100, 1000, 10000")
	flag.Parse()

	endpoints := []string{"127.0.0.1:10001", "127.0.0.1:10002", "127.0.0.1:10003"}
	if *mod == "get" {
		getOp(*numClient, *numQuery, *keyPrefix, *outCnt, endpoints)
	} else if *mod == "put" {
		putOp(*numClient, *numQuery, *keyPrefix, *valPrefix, endpoints)
	} else {
		log.Fatal("mod should be either 'put' or 'get'")
	}
}
```