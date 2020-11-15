# AWS go SDK 使用简介
介绍如何使用 aws 的 go sdk 创建 ec2 实例，并且可以 ssh 远程登录该 ec2 实例，以及如何销毁 ec2 实例

---

## aws cli
aws cli 是 amazon 提供的命令行工具，可以直接在命令行中操作 ec2 实例。可以直接使用 docker 运行 aws cli
```bash
$ docker run --rm -it amazon/aws-cli --version
aws-cli/2.0.56 Python/3.7.3 Linux/5.4.0-48-generic docker/x86_64.amzn.2
```
创建目录 `~/.aws`和 `~/work/asw`， 前者用于存储 aws cli 的密钥，后者为 aws 的工作目录
```bash
$ mkdir ~/.aws
$ mkdir ~/work/asw
```
在 `~/.bashrc` 中添加 aws cli 的别名
```bash
alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v ${HOME}/work/aws-work:/aws amazon/aws-cli'
```
用别名的方式运行 aws cli
```bash
$ aws --version
aws-cli/2.0.56 Python/3.7.3 Linux/5.4.0-48-generic docker/x86_64.amzn.2
```

---

## 配置 aws cli

按照这个页面 https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html 设置密钥，得到 `Access key ID` 和 `Secret access key`，格式类似如下:
```txt
Access key ID: AKIAIOSFODNN7EXAMPLE
Secret access key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```
运行 `aws configure` 配置 aws cli, `Access key ID` 和 `AWS Secret Access Key` 为前述页面得到的 aws 密钥, `region` 指定 ec2 实例默认在哪个区域创建，`output format` 指定 aws cli 在屏幕打印的输出格式
```bash
$ aws configure
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-2
Default output format [None]: json
```
配置完成后会在 `~/.aws` 目录下生成两个文件，`config` 和 `credentials`，内容为前面输入的配置项

`config` 文件内容
```ini
[default]
region = us-east-2
output = json 
```

`credentials` 文件内容
```ini
[default]
aws_access_key_id = AKIAIOSFODNN7EXAMPLE
aws_secret_access_key = wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

当前 aws cli 是在 docker 中运行的， 而 docker 中的用户为 root ，所以 `config` 和 `credentials` 的 owner 和 group 均为 root， 修改 owner 和 group 为当前用户
```bash
chown zilliz:zilliz ~/.aws/config
chown zilliz:zilliz ~/.aws/credentials
```
修改 `config` 和 `credentials` 的 owner 和 group 是非常重要的，因为后续的 go sdk 也需要使用这两个文件，如果权限不正确，可能导致 go sdk 无法访问这两个文件，进而运行失败

查询当前 aws 用户所有正在运行的 ec2 实例，检查 aws cli 配置是否正确
```bash
$ aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```
如果 aws 用户有正在运行的 ec2 实例，输出结果类似如下:
```json
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-0e84e211558a022c0",
                    "InstanceId": "i-0ae14f1360e606c51",
                    "InstanceType": "t2.micro",
                    "KeyName": "aws-key",
                    "LaunchTime": "2020-04-27T02:30:53+00:00",
...

```
如果 aws 用户没有正在运行的 ec2 实例， 输出结果类似如下:
```json
{
    "Reservations": []
}
```

---

## 配置 ssh 密钥对
ssh 密钥对用于远程登录 ec2 实例， 创建 ec2 实例需要指定 ssh 密钥对

如果 aws 用户没有密钥对，请按照这个页面 https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html 创建密钥对

创建密钥对后会下载一个 `.pem` 文件，为该密钥对的私钥，请妥善保存

---

## 配置 Security group
Security group 这是 ec2 的安全测试略，最简单的安全策略是 ip 地址白名单， 在这个安全策略中，我们规定只有本地的看法机器可以访问 ce2 的 ssh 端口

在这个网页 https://tool.lu/ip/ 查询本机的外网 ip 地址， 查询外网 ip 地址时请关闭浏览器的代理，否则得到的是代理服务器的 ip 地址

新建 Security group `test-sg`
```bash
$ aws ec2 create-security-group --group-name test-sg --description "ssh from local"   
{
    "GroupId": "sg-0d2524524c67cef97"
}
```

向 `test-sg` 中添加规则，允许本地开发机器可以远程访问 ec2 的 ssh 端口，其中 `116.228.99.250` 为本机的外网 ip 地址
```bash
$ aws ec2 authorize-security-group-ingress --group-name test-sg --protocol tcp --port 22 --cidr 116.228.99.250/32
```

查询 `test-sg` 确保成功添加规则
```bash
$ aws ec2 describe-security-groups --group-names test-sg
{
    "SecurityGroups": [
        {
            "Description": "ssh from local",
            "GroupName": "test-sg",
            "IpPermissions": [
                {
                    "FromPort": 22,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "116.228.99.250/32"
                        }
                    ],
...
```

---

## 创建 EC2 实例

```bash
$ aws ec2 run-instances --image-id ami-07efac79022b86107 --count 1 --instance-type t2.micro --key-name aws-key --security-groups test-sg
```
- `image-id` 指定了 ec2 实例的操作系统， ami-07efac79022b86107 表示运行 `Ubuntu Server 20.04 LTS (HVM), SSD Volume Type - ami-07efac79022b86107 (64-bit x86)` 。使用 `aws ec2 describe-images` 命令可以查看当前支持的所有 image id

- `instance-type` 指定了当前实例的 cpu 、 内存、磁盘等配置信息，详见 https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
- `key-name` 为之前创建的 ssh 密钥对
- `security-groups` 为之前创建的安全策略

`run-instances` 运行结果类似如下, `InstanceId` 为 `i-0f4e4d516ad6063d2`，刚启动的实例，State 为 `pending`
```json
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-07efac79022b86107",
            "InstanceId": "i-0f4e4d516ad6063d2",
            "InstanceType": "t2.micro",
            "KeyName": "aws-key",
            "LaunchTime": "2020-10-14T05:59:43+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-east-2b",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-172-31-29-241.us-east-2.compute.internal",
            "PrivateIpAddress": "172.31.29.241",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
...
```

使用以下命令，制定 `instance-id`， 反复查询刚刚创建的实例状态，直至 State 为 `running`

```bash
aws ec2 describe-instances --filters "Name=instance-id,Values=i-0f4e4d516ad6063d2"
```
运行结果类似如下：
```json
{
    "Reservations": [
        {
            "Groups": [],
            "Instances": [
                {
                    "AmiLaunchIndex": 0,
                    "ImageId": "ami-07efac79022b86107",
                    "InstanceId": "i-0f4e4d516ad6063d2",
                    "InstanceType": "t2.micro",
                    "KeyName": "aws-key",
                    "LaunchTime": "2020-10-14T05:59:43+00:00",
                    "Monitoring": {
                        "State": "disabled"
                    },
                    "Placement": {
                        "AvailabilityZone": "us-east-2b",
                        "GroupName": "",
                        "Tenancy": "default"
                    },
                    "PrivateDnsName": "ip-172-31-29-241.us-east-2.compute.internal",
                    "PrivateIpAddress": "172.31.29.241",
                    "ProductCodes": [],
                    "PublicDnsName": "ec2-18-220-101-251.us-east-2.compute.amazonaws.com",
                    "PublicIpAddress": "18.220.101.251",
                    "State": {
                        "Code": 16,
                        "Name": "running"
                    },

```

---

## SSH 远程登录 EC2
使用 `aws ec2 describe-instances --filters "Name=instance-id,Values=i-0f4e4d516ad6063d2"` 查询 ec2 实例的运行状态是，在返回结果中包含该实例的公网 ip 地址 `"PublicIpAddress": "18.220.101.251"`

使用 `配置 ssh 密钥对` 章节中提到的 `.pem` 私钥文件登录 ec2 实例
```bash
ssh -i ~/.ssh/aws-key.pem ubuntu@18.220.101.251
```
`aws-key.pem` 即为私钥文件

---

## 终止 EC2 实例
```bash
$ aws ec2 terminate-instances --instance-ids i-0f4e4d516ad6063d2
{
    "TerminatingInstances": [
        {
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "InstanceId": "i-0f4e4d516ad6063d2",
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}

```

---

## 安装 `go sdk`
```bash
go get -u github.com/aws/aws-sdk-go/...
```

## 使用 `go sdk` 创建 ec2 实例

`create_instance.go` 内容如下，该程序创建一个 ec2 实例，并不断查询其状态，直至就绪
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
		ImageId:        aws.String("ami-07efac79022b86107"),
		InstanceType:   aws.String("t2.micro"),
		KeyName:        aws.String("aws-key"),
		MaxCount:       aws.Int64(1),
		MinCount:       aws.Int64(1),
		SecurityGroups: []*string{aws.String("test-sg")},
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

编译 `create_instance.go`
```bash
go build -o create_instance create_instance.go
```

运行 `create_instance` 程序，创建实例，并打印其公网 ip 地址
```bash
$ ./create_instance 
reservation id = r-03bf771a7ea98969e
	 instance id = i-06e3a3f35a1aec95f, state = pending
start instance, id = i-06e3a3f35a1aec95f, public ip = 18.222.179.197, private ip = 172.31.6.151
```

---

## SSH 远程登录 EC2
```
$ ssh -i ~/.ssh/aws-key.pem ubuntu@18.222.179.197
```

---

## 使用 `go sdk` 终止 ec2 实例

`terminate_instance.go` 内容如下，该程序查询当前 aws 中正在运行的所有 ec2 实例，并终止第一个 ce2 实例
```go
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
```

编译 `terminate_instance.go`
```bash
go build -o terminate_instance terminate_instance.go
```

运行 `terminate_instance`
```bash
$ ./terminate_instance 
reservation id : r-03bf771a7ea98969e
	 instance id : i-06e3a3f35a1aec95f, state = running

instance id = i-06e3a3f35a1aec95f, current state = shutting-down, previous state = running
```

---

## 参考资料
- [Tools to Build on AWS](https://aws.amazon.com/tools/)
- [aws cli](https://aws.amazon.com/cli/)
- [aws cli docker](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-docker.html)
- [aws go sdk](https://aws.amazon.com/sdk-for-go/)
- [aws doc sdk examples](https://github.com/nezha2017/aws-doc-sdk-examples)
- [如何使用 --query 选项筛选输出](https://docs.aws.amazon.com/zh_cn/cli/latest/userguide/cli-usage-output.html#cli-usage-output-filter)
