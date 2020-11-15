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
