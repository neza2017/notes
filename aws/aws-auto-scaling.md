# auto scaling
启动扩容包含两层含义:
1. 当前 ec2 实例的 memory 或 cpu 不够用，需要升级当前实例的 memory 或 cpu，但是并不额外增加新的实例
2. 当前服务的算力不够，需要向当前服务群中加入新的 ec2 实例

针对第 1 中情况， aws 不能动态的对正在运行的 ec2 实例添加 memory 或 cpu，详见 [更改实例类型](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-instance-resize.html#resize-limitations)

本文主要讨论第 2 种情况，当服务群算力不够时，如何配置 aws 自动向当前服务群加入新的 ec2 实例，当算力富裕时，aws 如何自动的关掉多余的实例。

---

## 启动模板
按照 <https://docs.aws.amazon.com/zh_cn/autoscaling/ec2/userguide/LaunchTemplates.html> 设置，创建启动模板

查看启动模板
```bash
$ aws ec2 describe-launch-templates
{
    "LaunchTemplates": [
        {
            "LaunchTemplateId": "lt-0f57d836671bdfc9e",
            "LaunchTemplateName": "t2-micro",
            "CreateTime": "2020-10-19T10:04:47+00:00",
            "CreatedBy": "arn:aws:iam::393746910776:root",
            "DefaultVersionNumber": 1,
            "LatestVersionNumber": 1
        }
    ]
}
```

通过模板启动 ec2 实例
```bash
$ aws ec2 run-instances  --count 1 --launch-template LaunchTemplateName=t2-micro,Version=1  
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-07efac79022b86107",
            "InstanceId": "i-0b74c57031d7c34f3",
            "InstanceType": "t2.micro",
            "KeyName": "aws-key",
            "LaunchTime": "2020-10-19T10:34:54+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-east-2c",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-172-31-35-29.us-east-2.compute.internal",
            "PrivateIpAddress": "172.31.35.29",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
...
```

`go sdk` 代码
```go
package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
	"time"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	cli := ec2.New(sess)

	inst, err := cli.RunInstances(&ec2.RunInstancesInput{
		LaunchTemplate: &ec2.LaunchTemplateSpecification{
			LaunchTemplateName: aws.String("t2-micro"),
			Version:            aws.String("1"),
		},
		MaxCount: aws.Int64(1),
		MinCount: aws.Int64(1),
	})
	if err != nil {
		log.Fatal(err)
	}

	var instance_id string
	fmt.Printf("reservation id = %s\n", *inst.ReservationId)
	for _, i := range inst.Instances {
		fmt.Printf("\t instance id = %s, state = %s\n", *i.InstanceId, *i.State.Name)
		instance_id = *i.InstanceId
	}

	for {
		time.Sleep(100 * time.Millisecond)
		dins, err := cli.DescribeInstances(&ec2.DescribeInstancesInput{
			Filters: []*ec2.Filter{
				{Name: aws.String("instance-state-name"), Values: []*string{aws.String("running")}},
			},
		})
		if err != nil {
			log.Fatal(err)
		}
		for _, r := range dins.Reservations {
			for _, i := range r.Instances {
				if *i.InstanceId == instance_id {
					fmt.Printf("start instance, id = %s, public ip = %s, private ip = %s\n", *i.InstanceId, *i.PublicIpAddress, *i.PrivateIpAddress)
					return
				}
			}
		}
	}

}
```

程序输出
```txt
reservation id = r-03f85858b0fbdd9d6
         instance id = i-0e6f5ac020f2c7a24, state = pending
start instance, id = i-0e6f5ac020f2c7a24, public ip = 18.218.240.158, private ip = 172.31.43.90
```




## 参考文献
- [What steps do I need to take before changing the instance type of my EC2 Linux instance?](https://aws.amazon.com/premiumsupport/knowledge-center/resize-instance/)
- [更改实例类型](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/ec2-instance-resize.html#resize-limitations)
- [入门Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/zh_cn/autoscaling/ec2/userguide/GettingStartedTutorial.html)