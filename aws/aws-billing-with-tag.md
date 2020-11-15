# 按照标签过滤账单
按照 <https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/Using_Tags.html> 设置，给 EC2 实例添加标签，如果需要使用其它资源，也需要添加标签，属于同一个用户的资源，使用相同的标签

按照 <https://docs.amazonaws.cn/awsaccountbilling/latest/aboutv2/activating-tags.html> 设置，激活标签。新添加的标签类型可能无法立刻激活，需要等待一段时间

**注意** `Cost Explorer` API 调用是付费的，一次 `0.01` 美元或 `0.07` 人民币

---
## aws cli
列出当前所有 ec2 实例的 `tag`
```bash
$ aws ec2 describe-instances --profile cnnw1 \
                             --query 'Reservations[*].Instances[*].{id:InstanceId,tag:Tags[*]}' \
                             --output yaml
- - id: i-0f5c2c0e3eb458c1c
    tag:
    - Key: Name
      Value: pulsar2
  - id: i-081d62db743814df7
    tag:
    - Key: Name
      Value: pulsar1
- - id: i-029207d69cd39531c
    tag:
    - Key: Name
      Value: proxy3
  - id: i-0baadca44017143c3
    tag:
    - Key: Name
      Value: proxy4
- - id: i-0b4671b6c02a3a728
    tag:
    - Key: Name
      Value: sdk2
  - id: i-09b89b21dbd9fa527
    tag:
    - Key: Name
      Value: sdk1
  - id: i-00879b91cf475a597
    tag:
    - Key: Name
      Value: master
- - id: i-029053be08666bafd
    tag:
    - Key: Name
      Value: proxy1
  - id: i-0c9e6f2adaff0a1db
    tag:
    - Key: Name
      Value: proxy2

```

只查询 `Name` 为 `proxy1` 或 `proxy2` 在 `2020-10-14` 和 `2020-10-15` 这两天每天的费用

```bash
$ aws ce get-cost-and-usage --time-period Start=2020-10-14,End=2020-10-16 \
                            --metrics "UnblendedCost" \
                            --granularity DAILY \
                            --profile cnnw1 \
                            --filter '{"Tags":{"Key":"Name", "Values":["proxy1","proxy2"]}}' \
                            --output yaml
ResultsByTime:
- Estimated: true
  Groups: []
  TimePeriod:
    End: '2020-10-15'
    Start: '2020-10-14'
  Total:
    UnblendedCost:
      Amount: '0'
      Unit: CNY
- Estimated: true
  Groups: []
  TimePeriod:
    End: '2020-10-16'
    Start: '2020-10-15'
  Total:
    UnblendedCost:
      Amount: '29.1110073344'
      Unit: CNY
```

上述命令查询得到的是 `proxy1` 或 `proxy2` 的费用之和，可以使用 `group-by` 得到各自费用
```bash
$ aws ce get-cost-and-usage --time-period Start=2020-10-14,End=2020-10-16 \
                            --metrics "UnblendedCost" \
                            --granularity DAILY \
                            --profile cnnw1 \
                            --filter '{"Tags":{"Key":"Name", "Values":["proxy1","proxy2"]}}' \
                            --group-by Type=TAG,Key=Name \
                            --output yaml
GroupDefinitions:
- Key: Name
  Type: TAG
ResultsByTime:
- Estimated: true
  Groups: []
  TimePeriod:
    End: '2020-10-15'
    Start: '2020-10-14'
  Total:
    UnblendedCost:
      Amount: '0'
      Unit: CNY
- Estimated: true
  Groups:
  - Keys:
    - Name$proxy1
    Metrics:
      UnblendedCost:
        Amount: '14.5732706493'
        Unit: CNY
  - Keys:
    - Name$proxy2
    Metrics:
      UnblendedCost:
        Amount: '14.5377366851'
        Unit: CNY
  TimePeriod:
    End: '2020-10-16'
    Start: '2020-10-15'
  Total: {}
```

查询 `2020-10-15` 每个 ec2 实例的费用， 可以发现当天除了 `proxy1` 和 `proxy2` 之外，还有其它 `￥47.4272084484` 未打标签的费用消耗
```bash
$ aws ce get-cost-and-usage --time-period Start=2020-10-15,End=2020-10-16 \
                            --metrics "UnblendedCost" \
                            --granularity DAILY \
                            --profile cnnw1 \
                            --group-by Type=TAG,Key=Name \
                            --output yaml
GroupDefinitions:
- Key: Name
  Type: TAG
ResultsByTime:
- Estimated: true
  Groups:
  - Keys:
    - Name$
    Metrics:
      UnblendedCost:
        Amount: '47.4272084484'
        Unit: CNY
  - Keys:
    - Name$proxy1
    Metrics:
      UnblendedCost:
        Amount: '14.5732706493'
        Unit: CNY
  - Keys:
    - Name$proxy2
    Metrics:
      UnblendedCost:
        Amount: '14.5377366851'
        Unit: CNY
  TimePeriod:
    End: '2020-10-16'
    Start: '2020-10-15'
  Total: {}
```

---

## Go SDK
`billing_tag.go`
```go
package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/costexplorer"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		Profile:           "cnnw1",
		SharedConfigState: session.SharedConfigEnable,
	}))

	fmt.Println("list tags of ec2 instances:")
	inst_svr := ec2.New(sess)
	insts, err := inst_svr.DescribeInstances(nil)
	if err != nil {
		log.Fatal(err)
	}
	for _, r := range insts.Reservations {
		for _, i := range r.Instances {
			fmt.Printf("id = %s:\n", *i.InstanceId)
			for _, t := range i.Tags {
				fmt.Printf("\t key = %s, value = %s\n", *t.Key, *t.Value)
			}
		}
	}
	fmt.Println("===================")

	fmt.Println("filter the sum of proxy1 and proxy2:")
	ce_svr := costexplorer.New(sess)
	rst, err := ce_svr.GetCostAndUsage(&costexplorer.GetCostAndUsageInput{
		Filter: &costexplorer.Expression{
			Tags: &costexplorer.TagValues{
				Key:    aws.String("Name"),
				Values: []*string{aws.String("proxy1"), aws.String("proxy2")},
			},
		},
		Granularity: aws.String("DAILY"),
		Metrics:     []*string{aws.String("UnblendedCost")},
		TimePeriod: &costexplorer.DateInterval{
			End:   aws.String("2020-10-16"),
			Start: aws.String("2020-10-14"),
		},
	})
	if err != nil {
		log.Fatal(err)
	}
	for _, r := range rst.ResultsByTime {
		fmt.Printf("date %s, cost = %s %s\n", *r.TimePeriod.Start, *r.Total["UnblendedCost"].Amount, *r.Total["UnblendedCost"].Unit)
	}
	fmt.Println("===================")

	fmt.Println("filter each cost of proxy1 and proxy2:")
	rst, err = ce_svr.GetCostAndUsage(&costexplorer.GetCostAndUsageInput{
		Filter: &costexplorer.Expression{
			Tags: &costexplorer.TagValues{
				Key:    aws.String("Name"),
				Values: []*string{aws.String("proxy1"), aws.String("proxy2")},
			},
		},
		Granularity: aws.String("DAILY"),
		GroupBy: []*costexplorer.GroupDefinition{
			{Type: aws.String("TAG"), Key: aws.String("Name")},
		},
		Metrics: []*string{aws.String("UnblendedCost")},
		TimePeriod: &costexplorer.DateInterval{
			End:   aws.String("2020-10-16"),
			Start: aws.String("2020-10-14"),
		},
	})
	if err != nil {
		log.Fatal(err)
	}
	for _, r := range rst.ResultsByTime {
		fmt.Printf("data %s, ", *r.TimePeriod.Start)
		if len(r.Groups) == 0 {
			fmt.Printf("cost = %s\n", *r.Total["UnblendedCost"].Amount)
		} else {
			fmt.Printf("cost :")
			for _, g := range r.Groups {
				fmt.Printf(" %s=%s(%s)", *g.Keys[0], *g.Metrics["UnblendedCost"].Amount, *g.Metrics["UnblendedCost"].Unit)
			}
			fmt.Printf("\n")
		}
	}
	fmt.Println("===================")

	fmt.Println("filter cost of each ce2 instance:")
	rst, err = ce_svr.GetCostAndUsage(&costexplorer.GetCostAndUsageInput{
		Granularity: aws.String("DAILY"),
		GroupBy: []*costexplorer.GroupDefinition{
			{Type: aws.String("TAG"), Key: aws.String("Name")},
		},
		Metrics: []*string{aws.String("UnblendedCost")},
		TimePeriod: &costexplorer.DateInterval{
			End:   aws.String("2020-10-16"),
			Start: aws.String("2020-10-14"),
		},
	})
	if err != nil {
		log.Fatal(err)
	}
	for _, r := range rst.ResultsByTime {
		fmt.Printf("data %s, ", *r.TimePeriod.Start)
		if len(r.Groups) == 0 {
			fmt.Printf("cost = %s\n", *r.Total["UnblendedCost"].Amount)
		} else {
			fmt.Printf("cost :")
			for _, g := range r.Groups {
				fmt.Printf(" %s=%s(%s)", *g.Keys[0], *g.Metrics["UnblendedCost"].Amount, *g.Metrics["UnblendedCost"].Unit)
			}
			fmt.Printf("\n")
		}
	}
}
```
程序输出:
```txt
list tags of ec2 instances:
id = i-0f5c2c0e3eb458c1c:
         key = Name, value = pulsar2
id = i-081d62db743814df7:
         key = Name, value = pulsar1
id = i-029207d69cd39531c:
         key = Name, value = proxy3
id = i-0baadca44017143c3:
         key = Name, value = proxy4
id = i-0b4671b6c02a3a728:
         key = Name, value = sdk2
id = i-09b89b21dbd9fa527:
         key = Name, value = sdk1
id = i-00879b91cf475a597:
         key = Name, value = master
id = i-029053be08666bafd:
         key = Name, value = proxy1
id = i-0c9e6f2adaff0a1db:
         key = Name, value = proxy2
===================
filter the sum of proxy1 and proxy2:
date 2020-10-14, cost = 0 CNY
date 2020-10-15, cost = 29.1110073344 CNY
===================
filter each cost of proxy1 and proxy2:
data 2020-10-14, cost = 0
data 2020-10-15, cost : Name$proxy1=14.5732706493(CNY) Name$proxy2=14.5377366851(CNY)
===================
filter cost of each ce2 instance:
data 2020-10-14, cost : Name$=368.4701820601(CNY)
data 2020-10-15, cost : Name$=47.4272084484(CNY) Name$proxy1=14.5732706493(CNY) Name$proxy2=14.5377366851(CNY)
```

---

## Q & A

### EC2-Other 是由哪些操作产生的费用 ?
针对Cost Explorer中EC2-Other的内容，您可尝试在“分组依据”中选择“使用类型”，并在“服务”中选择“EC2-其他”，即可呈现出“EC2-其他”所涉及的具体服务分类。如：EBS卷，EBS快照，数据传输等。

### Unblended costs, Amortized costs, Blended costs, Net unblended costs, Net amortized costs ，这些分别有什么区别 ?
1. Unblended costs您可以理解为定价页面中的价格，此价格与定价页面价格一致；
2. Amortized costs为分摊成本，会按照您的的总成本，根据您选择的时间颗粒度进行分摊。如您在01月01日购买了一年期全预付的预留实例共计600元，当您的时间颗粒度选择“每月”时，该Amortized costs即为600/12=50元；
3. Blended costs 是 AWS Organizations 中的组织的成员账户使用的预留实例和按需实例的平均费率。目前您当前账号并未在 AWS Organizations 中，故暂不涉及。相关文档，可参考如下链接了解：
https://docs.amazonaws.cn/awsaccountbilling/latest/aboutv2/con-bill-blended-rates.html#Blended_CB
4. 目前中国区暂未支持Net unblended costs, Net amortized costs，还望您知悉。


## 参考资料
- [给您的 Amazon EC2 资源加标签](https://docs.amazonaws.cn/AWSEC2/latest/UserGuide/Using_Tags.html)
- [激活用户定义的成本分配标签](https://docs.amazonaws.cn/awsaccountbilling/latest/aboutv2/activating-tags.html)
- [get-cost-and-usage](https://docs.aws.amazon.com/cli/latest/reference/ce/get-cost-and-usage.html)