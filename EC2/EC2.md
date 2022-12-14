# EC2
## Obtaining the Name tag of an EC2 instance
```
aws ec2 describe-instances --instance-ids INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Name`].Value' --output text
```

## Get information on all instances
```
aws ec2 describe-instances | jq '.Reservations[].Instances[]'
```

## Get PublicIpAddress
```
aws ec2 describe-instances | jq '.Reservations [] .Instances [] .PublicIpAddress'
```

## Get Public IP and Public DNS Name for all instances
```
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {PublicDnsName, PublicIpAddress}' 
```

## List global IPs (Elastic IPs) obtained by AWS EC2 via CLI
```
aws ec2 describe-addresses | jq '.[] | .[] | .PublicIp' | sed 's/\"//g'
```

## Get the Tag Name of all instances
```
aws ec2 describe-instances | jq '.Reservations[].Instances[]|{InstanceId, Tags}' 
```

## Obtain the information necessary to access the instances via ssh
```
aws ec2 describe-instances --filters Name=tag-value,Values="XXXX" |jq '.Reservations[].Instances[]|{InstanceId,PublicIpAddress,PrivateIpAddress,Tags}' 
```

## Obtain instance ID
```
aws ec2 describe-instances | jq -r '.Reservations[] .Instances[] .InstanceId'
aws ec2 describe-instances | jq '.Reservations[] .Instances[] .InstanceId'
```

## Get a list of Elastic IPs
```
aws ec2 describe-addresses | jq '.Addresses[].PublicIp'
```

## Get a list of PublicDnsName, PublicIpAddress, Tags
```
aws ec2 describe-instances | jq '.Reservations[].Instances[] | {PublicDnsName, PublicIpAddress, Tags}'
```

## Obtain a list of instances running AutoScaling, including their status, InstanceID, PublicDnsName, and PublicIpAddress
```
aws ec2 describe-instances --filters "Name=tag:aws:autoscaling:groupName,Values=YOUR AUTOSCALING GROUP NAME" | jq '.Reservations[].Instances[] | {State, InstanceId, PublicDnsName, PublicIpAddress}'
```

## Check the list of stopped instance IDs
```
aws ec2 describe-instances --filter "Name=instance-state-name,Values=stopped" --query 'Reservations[].Instances[].[InstanceId]'
```

## Disable delete protection
```
aws ec2 modify-instance-attribute --instance-id i-xxxxxx --no-disable-api-termination
```

# Get private ip of running instances with specific tags
```
aws ec2 describe-instances --filter "Name=tag-key,Values=prj" "Name=tag-value,Values=demo" --query 'Reservations[].Instances[?State.Name==`running`].PrivateIpAddress[]' --region ap-northeast-1
```

# Obtain OS information for an instance
```
aws ssm describe-instance-information --query 'InstanceInformationList[*].[InstanceId,PlatformType,PlatformName,PlatformVersion]' --output table
```

# AMI
## Obtain a list of AMI Name and ImageId created by you
```
aws ec2 describe-images --owners self | jq '.Images[] | {Name, ImageId}'
```

## Obtain a list of Names and ImageId with a specific tag for AMIs created by you
```
aws ec2 describe-images --owners self --filter Name=tag-key,Values=YOUR TAG NAME Name=tag-value,Values=YOUR TAG VALUES | jq '.Images[] | {Name, ImageId}'
```

## Create AMI (with time stamp)
```
aws ec2 --region ap-northeast-1 create-image --instance-id i-xxxxx --name base-$(date +%Y%m%d%H%M%S) --description 'created by '$(date +%Y%m%d%H%M%S) --no-reboot
```

# Snapshot
## Obtain a list of SnapshotId with a specific tag for a Snapshot created by you
```
aws ec2 describe-snapshots --filter Name=tag-key,Values=YOUR TAG NAME Name=tag-value,Values=YOUR TAG VALUES | jq '.Snapshots[] .SnapshotId'
```
## Obtain a list of volumeId,SnapshotId,Size of EBS in Tokyo region
```
aws ec2 describe-volumes --region ap-northeast-1 | jq '.Volumes[]| {VolumeId, SnapshotId, Size}'
```

# AutoScaling
## Obtain instance IDs running in the target AutoScaling group
```
aws ec2 describe-instances --filter 'Name=tag:aws:autoscaling:groupName,Values=demo-asg' "Name=instance-state-name,Values=running" | jq '.Reservations[].Instances[] | {InstanceId}'
```

## Update instances in the Auto Scaling group (change min, max)
```
aws autoscaling update-auto-scaling-group --auto-scaling-group-name demo-asg --min-size 2 --max-size 8
```

## Execute AutoScaling schedule
```
aws autoscaling put-scheduled-update-group-action --auto-scaling-group-name demo-asg --scheduled-action-name "demo-scaling-1100-1500" --recurrence "0 2 * * *" --min-size 2 --max-size 8 --desired-capacity 3
```

## Configure instances configured in the AutoScaling group
```
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names demo-asg | jq '.AutoScalingGroups[] | {MinSize, DesiredCapacity, MaxSize}'
```

## EBS snapshot creation (with time stamp)
```
aws ec2 --region ap-northeast-1 create-snapshot --volume-id vol-xxxxx --description 'created by '$(date +%Y%m%d%H%M%S)
```

# security groups
## Specify security group ID and confirm settings
```
 aws ec2 describe-security-groups --query 'SecurityGroups[?GroupId==`sg-12345678`]'
```

## Add to security group Inbound
```
aws --region ap-northeast-1 ec2 authorize-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 80 --cidr 192.168.10.1/32
```

## Remove from security group Inbound
```
aws --region ap-northeast-1 ec2 revoke-security-group-ingress --group-id sg-xxxxxxxx --protocol tcp --port 80 --cidr 192.168.10.1/32
```

# Region list acquisition
```
aws ec2 describe-regions --output table --profile dev
```