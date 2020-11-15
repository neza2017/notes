# 创建实例时设置标签
启动实例，设置磁盘为 30G, 存储资源和计算资源使用相同的 TAG , key 为 `milvus-user` value 为 `sanitizer`

```bash
aws ec2 run-instances --image-id ami-07efac79022b86107 \
                      --count 1 \
                      --instance-type t2.micro \
                      --key-name aws-key \
                      --security-groups test-sg \
                      --block-device-mappings 'DeviceName=/dev/sda1,Ebs={DeleteOnTermination=true,VolumeSize=30,VolumeType=gp2,Encrypted=false}' \
                      --tag-specifications 'ResourceType=instance,Tags=[{Key=milvus-user,Value=sanitizer}]' 'ResourceType=volume,Tags=[{Key=milvus-user,Value=sanitizer}]' 
```

`instance_tag.go`
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
		BlockDeviceMappings: []*ec2.BlockDeviceMapping{
			{
				DeviceName: aws.String("/dev/sda1"),
				Ebs: &ec2.EbsBlockDevice{
					DeleteOnTermination: aws.Bool(true),
					Encrypted:           aws.Bool(false),
					VolumeSize:          aws.Int64(30),
					VolumeType:          aws.String("gp2"),
				},
			},
		},
		ImageId:        aws.String("ami-07efac79022b86107"),
		InstanceType:   aws.String("t2.micro"),
		KeyName:        aws.String("aws-key"),
		MaxCount:       aws.Int64(1),
		MinCount:       aws.Int64(1),
		SecurityGroups: []*string{aws.String("launch-wizard-1")},
		TagSpecifications: []*ec2.TagSpecification{
			{
				ResourceType: aws.String("instance"),
				Tags: []*ec2.Tag{
					{Key: aws.String("milvus-user"), Value: aws.String("sanitizer")},
				},
			},
			{
				ResourceType: aws.String("volume"),
				Tags: []*ec2.Tag{
					{Key: aws.String("milvus-user"), Value: aws.String("sanitizer")},
				},
			},
		},
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
					fmt.Printf("start instance, id = %s, public ip = %s, private ip = %s", *i.InstanceId, *i.PublicIpAddress, *i.PrivateIpAddress)
					for _, t := range i.Tags {
						fmt.Printf(" $%s = %s", *t.Key, *t.Value)
					}
					fmt.Println()
					return
				}
			}
		}
	}
}
```
程序运行效果如下 :
```txt
reservation id = r-0fbbd017caa178cd1
         instance id = i-0ce509cc2ebfdc3fb, state = pending
start instance, id = i-0ce509cc2ebfdc3fb, public ip = 3.15.215.141, private ip = 172.31.38.255 $milvus-user = sanitizer

```

## 参考资料
- [Amazon EC2 Auto Scaling](https://docs.aws.amazon.com/zh_cn/autoscaling/ec2/userguide/what-is-amazon-ec2-auto-scaling.html)
- [run-instances](https://docs.aws.amazon.com/cli/latest/reference/ec2/run-instances.html)
- [block-device-mapping-concepts](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/block-device-mapping-concepts.html)
- [Using_Tags](https://docs.aws.amazon.com/zh_cn/AWSEC2/latest/UserGuide/Using_Tags.html)