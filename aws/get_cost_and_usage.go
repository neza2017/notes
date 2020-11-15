package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/costexplorer"
	"log"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	cli := costexplorer.New(sess)
	rst, err := cli.GetCostAndUsage(&costexplorer.GetCostAndUsageInput{
		Granularity: aws.String("MONTHLY"),
		Metrics: aws.StringSlice([]string{
			"AmortizedCost",
			"BlendedCost",
			"NetAmortizedCost",
			"NetUnblendedCost",
			"NormalizedUsageAmount",
			"UnblendedCost",
			"UsageQuantity",
		}),
		TimePeriod: &costexplorer.DateInterval{
			End:   aws.String("2020-10-01"),
			Start: aws.String("2020-08-01"),
		},
	})
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Cost report: ", rst.ResultsByTime)
}
