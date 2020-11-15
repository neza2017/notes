# aws 费用查询
## 启动 `Cost Explorer` 分析
按照 https://docs.aws.amazon.com/zh_cn/awsaccountbilling/latest/aboutv2/ce-enable.html 启动 `Cost Explorer` 分析

---

## aws cli 获得 cost explorer
```bash
aws ce get-cost-and-usage --time-period Start=2020-08-01,End=2020-10-01 --metrics  "AmortizedCost" "BlendedCost" "NetAmortizedCost" "NetUnblendedCost" "NormalizedUsageAmount" "UnblendedCost" "UsageQuantity" --granularity MONTHLY
{
    "ResultsByTime": [
        {
            "TimePeriod": {
                "Start": "2020-08-01",
                "End": "2020-09-01"
            },
            "Total": {
                "AmortizedCost": {
                    "Amount": "0",
                    "Unit": "USD"
                },
                "BlendedCost": {
                    "Amount": "0",
                    "Unit": "USD"
                },
                "NetAmortizedCost": {
                    "Amount": "0",
                    "Unit": "USD"
                },
                "NetUnblendedCost": {
                    "Amount": "0",
                    "Unit": "USD"
                },
                "NormalizedUsageAmount": {
                    "Amount": "372",
                    "Unit": "N/A"
                },
                "UnblendedCost": {
                    "Amount": "0",
                    "Unit": "USD"
                },
                "UsageQuantity": {
                    "Amount": "775.2684462154",
                    "Unit": "N/A"
                }
            },
            "Groups": [],
            "Estimated": false
        },
        {
            "TimePeriod": {
                "Start": "2020-09-01",
                "End": "2020-10-01"
            },
            "Total": {
                "AmortizedCost": {
                    "Amount": "0.000000232",
                    "Unit": "USD"
                },
                "BlendedCost": {
                    "Amount": "0.000000232",
                    "Unit": "USD"
                },
                "NetAmortizedCost": {
                    "Amount": "0.000000232",
                    "Unit": "USD"
                },
                "NetUnblendedCost": {
                    "Amount": "0.000000232",
                    "Unit": "USD"
                },
                "NormalizedUsageAmount": {
                    "Amount": "360",
                    "Unit": "N/A"
                },
                "UnblendedCost": {
                    "Amount": "0.000000232",
                    "Unit": "USD"
                },
                "UsageQuantity": {
                    "Amount": "751.8537176257",
                    "Unit": "N/A"
                }
            },
            "Groups": [],
            "Estimated": false
        }
    ]
}
```

---

## go sdk 获得获得 cost explorer
`get_cost_and_usage.go`
```go
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
```

---

## 参考文档
- https://docs.aws.amazon.com/cli/latest/reference/ce/index.html#cli-aws-ce
- https://docs.aws.amazon.com/aws-cost-management/latest/APIReference/Welcome.html
- https://docs.aws.amazon.com/zh_cn/awsaccountbilling/latest/aboutv2/billing-what-is.html
