package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
	"log"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	cli := ec2.New(sess)
	filter_state_name := "instance-state-name"
	filter_state_running := "running"
	inst, err := cli.DescribeInstances(&ec2.DescribeInstancesInput{
		DryRun: nil,
		Filters: []*ec2.Filter{
			{Name: &filter_state_name, Values: []*string{&filter_state_running}},
		},
		InstanceIds: nil,
		MaxResults:  nil,
		NextToken:   nil,
	})
	if err != nil {
		log.Fatal(err)
	}

	var first_id string

	for _, r := range inst.Reservations {
		fmt.Printf("reservation id : %s\n", *r.ReservationId)
		for _, i := range r.Instances {
			fmt.Printf("\t instance id : %s, state = %s\n", *i.InstanceId, *i.State.Name)
			if len(first_id) == 0 {
				first_id = *i.InstanceId
			}
		}
		fmt.Println("")
	}
	term, err := cli.TerminateInstances(&ec2.TerminateInstancesInput{
		DryRun:      nil,
		InstanceIds: []*string{&first_id},
	})
	if err != nil {
		log.Fatal(err)
	}
	for _, t := range term.TerminatingInstances {
		fmt.Printf("instance id = %s, current state = %s, previous state = %s\n", *t.InstanceId, *t.CurrentState.Name, *t.PreviousState.Name)
	}
}
