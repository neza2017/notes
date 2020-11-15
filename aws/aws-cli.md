# AWS SDK

## aws command line
在 `docker` 中运行 `aws-cli`
```bash
docker run --rm -it amazon/aws-cli --version
```
输出
```bash
aws-cli/2.0.56 Python/3.7.3 Linux/5.4.0-48-generic docker/x86_64.amzn.2
```
设置别名
```bash
alias aws='docker run --rm -it -v ~/.aws:/root/.aws -v ${HOME}/work/aws-work:/aws amazon/aws-cli'
```

---

## 设置 aws cli
设置 [`Access key ID and secret access key`](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)

设置完成后 `~/.aws` 目录下生成两个文件 `config` 和 `credentials`，如果使用 `docker` 方式启动，则该两文件的 `owner` 均为 `root`，修改其 `owner` 为当前用户 

---

## 查看当前所有运行实例

访问自己的 `EC2` 实例
```bash
aws ec2 describe-instances  --filters "Name=instance-state-name,Values=running"
```
返回类似以下内容:
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

---

## 关闭实例
```bash
aws ec2 terminate-instances --instance-ids i-0e46dab7a5e487e26
```
输出结果
```bash
{
    "TerminatingInstances": [
        {
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "InstanceId": "i-0e46dab7a5e487e26",
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}

```

---

## 创建实例
```bash
aws ec2 run-instances --image-id ami-07efac79022b86107 --count 1 --instance-type t2.micro --key-name aws-key --security-groups launch-wizard-1
```
输出类似如下
```json
{
    "Groups": [],
    "Instances": [
        {
            "AmiLaunchIndex": 0,
            "ImageId": "ami-07efac79022b86107",
            "InstanceId": "i-0f9972e15d674b79f",
            "InstanceType": "t2.micro",
            "KeyName": "aws-key",
            "LaunchTime": "2020-10-13T10:10:13+00:00",
            "Monitoring": {
                "State": "disabled"
            },
            "Placement": {
                "AvailabilityZone": "us-east-2c",
                "GroupName": "",
                "Tenancy": "default"
            },
            "PrivateDnsName": "ip-172-31-40-236.us-east-2.compute.internal",
            "PrivateIpAddress": "172.31.40.236",
            "ProductCodes": [],
            "PublicDnsName": "",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
...
```


---


## 安装 `Go SDK`
```bash
go get -u github.com/aws/aws-sdk-go/...
```

## 下载示例
```bash
git clone https://github.com/nezha2017/aws-doc-sdk-examples.git
```

## 编译并运行示例
```bash
cd aws-doc-sdk-examples/go/ec2/DescribeInstances
go build -o DescribeInstances DescribeInstances.go
 ./DescribeInstances
```
输出类似如下:
```bash
Reservation ID: r-0d12c2466e03d6cba
Instance IDs:
   i-0ae14f1360e606c51
```
