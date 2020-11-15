package main

import (
	"fmt"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ec2"
)

func main() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	cli := ec2.New(sess)

	regions, err := cli.DescribeRegions(nil)
	if err != nil {
		fmt.Println("Error", err)
		return
	}
	for _, reg := range regions.Regions {
		fmt.Printf("endpoint : %s \t name : %s\n", *reg.Endpoint, *reg.RegionName)
	}

	all_zone := false
	zones, err := cli.DescribeAvailabilityZones(&ec2.DescribeAvailabilityZonesInput{
		AllAvailabilityZones: &all_zone,
		DryRun:               nil,
		Filters:              nil,
		ZoneIds:              nil,
		ZoneNames:            nil,
	})
	for _, zone := range zones.AvailabilityZones {
		fmt.Printf("group name :  %s \t", *zone.GroupName)
		fmt.Printf("region name :  %s \t", *zone.RegionName)
		fmt.Printf("zone id :  %s \t", *zone.ZoneId)
		fmt.Printf("zone name :  %s\n", *zone.ZoneName)
	}
}
