package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		Profile:           "cnnw1",
		SharedConfigState: session.SharedConfigEnable,
	}))
	cli := ec2.New(sess)

	insts, err := cli.DescribeInstances(nil)
	if err != nil {
		log.Fatal(err)
	}
	for _, r := range insts.Reservations {
		for _, i := range r.Instances {
			fmt.Printf("id :%s,state %s\n", *i.InstanceId, *i.State.Name)
		}
	}

}
