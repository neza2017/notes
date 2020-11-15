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
