# VPC
## Create VPC
```
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --tag-specifications 'ResourceType=vpc, Tags=[{Key=Name, Value=aws-example-vpc}]'
```
## Describe VPC
```
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=tag:Name,Values=aws-example-vpc" \
  --query "Vpcs[].[VpcId]" \
  --output text)
echo $VPC_ID
```


# Subnet
## Create Subnet
```
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --availability-zone ap-northeast-1a \
  --cidr-block 10.0.1.0/24 \
  --tag-specifications \
  'ResourceType=subnet,Tags=[{Key=Name, Value=aws-example-public-subnet-a}]' && \
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --availability-zone ap-northeast-1c \
  --cidr-block 10.0.2.0/24 \
  --tag-specifications \
  'ResourceType=subnet,Tags=[{Key=Name, Value=aws-example-public-subnet-c}]' && \
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --availability-zone ap-northeast-1a \
  --cidr-block 10.0.10.0/24 \
  --tag-specifications \
  'ResourceType=subnet,Tags=[{Key=Name, Value=aws-example-private-subnet-a}]' && \
aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --availability-zone ap-northeast-1c \
  --cidr-block 10.0.11.0/24 \
  --tag-specifications \
  'ResourceType=subnet,Tags=[{Key=Name, Value=aws-example-private-subnet-c}]'
```
## Describe Subnet
```
SUBNET_PUBLIC_AZ_A_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-public-subnet-a" \
  --query "Subnets[].[SubnetId]" \
  --output text) && \
SUBNET_PUBLIC_AZ_C_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-public-subnet-c" \
  --query "Subnets[].[SubnetId]" \
  --output text) && \
SUBNET_PRIVATE_AZ_A_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-private-subnet-a" \
  --query "Subnets[].[SubnetId]" \
  --output text) && \
SUBNET_PRIVATE_AZ_C_ID=$(aws ec2 describe-subnets \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-private-subnet-c" \
  --query "Subnets[].[SubnetId]" \
  --output text)
echo $SUBNET_PUBLIC_AZ_A_ID
echo $SUBNET_PUBLIC_AZ_C_ID
echo $SUBNET_PRIVATE_AZ_A_ID
echo $SUBNET_PRIVATE_AZ_C_ID
```

# Internet Gatway
## Create Internet Gatway
```
aws ec2 create-internet-gateway \
  --tag-specifications \
  'ResourceType=internet-gateway,Tags=[{Key=Name, Value=aws-example-igw}]' 
```
## Describe Internet Gatway
```
IGW_ID=$(aws ec2 describe-internet-gateways \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-igw" \
  --query "InternetGateways[].[InternetGatewayId]" \
  --output text)
echo $IGW_ID
```

## Attach Internet Gatway
```
aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID
```

# Route Table
## Create Route Table
```
aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications \
  'ResourceType=route-table,Tags=[{Key=Name, Value=aws-example-public-route-table}]' && \
aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --tag-specifications \
  'ResourceType=route-table,Tags=[{Key=Name, Value=aws-example-private-route-table}]'
```
## Describe Route Table
```
ROUTE_TABLE_PUBLIC_ID=$(aws ec2 describe-route-tables \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-public-route-table" \
  --query "RouteTables[].[RouteTableId]" \
  --output text)
ROUTE_TABLE_PRIVATE_ID=$(aws ec2 describe-route-tables \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-private-route-table" \
  --query "RouteTables[].[RouteTableId]" \
  --output text)
echo $ROUTE_TABLE_PUBLIC_ID
echo $ROUTE_TABLE_PRIVATE_ID
```
## Create Route to Internet Gatway
```
aws ec2 create-route \
  --route-table-id $ROUTE_TABLE_PUBLIC_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID
```

## Add Route Table to Subnet
```
aws ec2 associate-route-table \
  --subnet-id $SUBNET_PUBLIC_AZ_A_ID \
  --route-table-id $ROUTE_TABLE_PUBLIC_ID && \
aws ec2 associate-route-table \
  --subnet-id $SUBNET_PUBLIC_AZ_C_ID \
  --route-table-id $ROUTE_TABLE_PUBLIC_ID && \
aws ec2 associate-route-table \
  --subnet-id $SUBNET_PRIVATE_AZ_A_ID \
  --route-table-id $ROUTE_TABLE_PRIVATE_ID && \
aws ec2 associate-route-table \
  --subnet-id $SUBNET_PRIVATE_AZ_C_ID \
  --route-table-id $ROUTE_TABLE_PRIVATE_ID
```

## Enable Public IP Assignment at Instance Creation
```
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC_AZ_A_ID \
  --map-public-ip-on-launch && \
aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_PUBLIC_AZ_C_ID \
  --map-public-ip-on-launch
```

## Your Global IP
```
LOCAL_GLOBAL_IP=$(curl https://checkip.amazonaws.com/)
echo $LOCAL_GLOBAL_IP
```

# Security Group for EC2
## Create Security Group
```
aws ec2 create-security-group \
  --description "Security group for aws example ec2" \
  --group-name "aws-example-ec2-sg" \
  --vpc-id $VPC_ID \
  --tag-specifications \
  'ResourceType=security-group,Tags=[{Key=Name, Value=aws-example-ec2-sg}]'
```
## Describe Security Group
```
SECURITY_GROUP_FOR_EC2=$(aws ec2 describe-security-groups \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-ec2-sg" \
  --query "SecurityGroups[].[GroupId]" \
  --output text)
echo $SECURITY_GROUP_FOR_EC2
```
## Add Authorize to Security Group
```
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_FOR_EC2 \
  --protocol tcp \
  --port 80 \
  --cidr $LOCAL_GLOBAL_IP'/32'
```
## Describe Security Group
```
aws ec2 describe-security-groups \
  --filters "Name=tag:Name,Values=aws-example-ec2-sg" \
  --query "SecurityGroups[].IpPermissions"
```

# IAM Role
## Create policy.json
```
vim ec2-role-trust-policy.json
```
```
{
        "Version": "2012-10-17",
        "Statement": [
                {
                        "Effect": "Allow",
                        "Principal": { "Service": "ec2.amazonaws.com" },
                        "Action": "sts:AssumeRole"
                }
        ]
}
```
## Create IAM Role
```
aws iam create-role \
  --role-name aws-example-ec2-role \
  --assume-role-policy-document file://ec2-role-trust-policy.json
```
## Add IAM Policy to IAM Role
```
aws iam attach-role-policy \
  --role-name aws-example-ec2-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
```
## Describe IAM Policy Attached to IAM Role
```
aws iam list-attached-role-policies \
  --role-name aws-example-ec2-role
```
## Create Instance Profile
```
aws iam create-instance-profile \
  --instance-profile-name aws-example-ec2-instance-profile
```
## Attach IAM Role to Instance Profile
```
aws iam add-role-to-instance-profile \
  --instance-profile-name aws-example-ec2-instance-profile \
  --role-name aws-example-ec2-role
```
```
aws iam get-instance-profile \
  --instance-profile-name aws-example-ec2-instance-profile \
  --query "InstanceProfile.Roles[].[RoleNamem,AssumeRolePolicyDocument]"
```
## Get AmazonLinux2 AMI for latest version
```
AMAZON_LINUX_LATEST_AMI=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --query "Parameters[].[Value]" \
  --output text)
echo $AMAZON_LINUX_LATEST_AMI
```

# EC2
## Create User Data text
```
vim user_data.txt
```
```
#!/bin/bash
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-7.noarch.rpm
sudo yum-config-manager --enable mysql80-community
sudo yum-config-manager --disable mysql57-community
sudo yum install -y mysql-community-client
```
## Create Instance
```
aws ec2 run-instances \
  --image-id $AMAZON_LINUX_LATEST_AMI \
  --count 1 \
  --instance-type t3.micro \
  --security-group-ids $SECURITY_GROUP_FOR_EC2 \
  --subnet-id $SUBNET_PUBLIC_AZ_A_ID \
  --user-data file://user_data.txt \
  --iam-instance-profile Name=aws-example-ec2-instance-profile \
  --block-device-mappings \
    "DeviceName=/dev/xvda,\
    Ebs={VolumeSize=8,\
    DeleteOnTermination="true",\
    VolumeType=gp3}" \
  --tag-specifications \
  'ResourceType=instance,Tags=[{Key=Name, Value=aws-example-ec2-1}]' && \
aws ec2 run-instances \
  --image-id $AMAZON_LINUX_LATEST_AMI \
  --count 1 \
  --instance-type t3.micro \
  --security-group-ids $SECURITY_GROUP_FOR_EC2 \
  --subnet-id $SUBNET_PUBLIC_AZ_C_ID \
  --user-data file://user_data.txt \
  --iam-instance-profile Name=aws-example-ec2-instance-profile \
  --block-device-mappings \
    "DeviceName=/dev/xvda,\
    Ebs={VolumeSize=8,\
    DeleteOnTermination="true",\
    VolumeType=gp3}" \
  --tag-specifications \
  'ResourceType=instance,Tags=[{Key=Name, Value=aws-example-ec2-2}]'
```
## Describe Instance
```
EC2_INSTANCE_A_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=aws-example-ec2-1" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text) && \
EC2_INSTANCE_C_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=aws-example-ec2-2" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)
echo $EC2_INSTANCE_A_ID
echo $EC2_INSTANCE_C_ID
```
## Describe Instance Status
```
aws ec2 describe-instance-status \
  --instance-ids $EC2_INSTANCE_A_ID \
  --query "InstanceStatuses[].[InstanceStatus,SystemStatus]" \
  --output table & \
aws ec2 describe-instance-status \
  --instance-ids $EC2_INSTANCE_C_ID \
  --query "InstanceStatuses[].[InstanceStatus,SystemStatus]" \
  --output table
```
## Describe Instance Private IP Address
```
EC2_INSTANCE_A_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $EC2_INSTANCE_A_ID \
  --query "Reservations[].Instances[].PrivateIpAddress[]" \
  --output text) && \
EC2_INSTANCE_C_PRIVATE_IP=$(aws ec2 describe-instances \
  --instance-ids $EC2_INSTANCE_C_ID \
  --query "Reservations[].Instances[].PrivateIpAddress[]" \
  --output text)
echo $EC2_INSTANCE_A_PRIVATE_IP
echo $EC2_INSTANCE_C_PRIVATE_IP
```

## Connecting to Instance with Session Manager
```
aws ssm start-session \
  --target $EC2_INSTANCE_A_ID
```
```
aws ssm start-session \
  --target $EC2_INSTANCE_C_ID
```

# AMI
## Create AMI
```
aws ec2 create-image \
  --instance-id $EC2_INSTANCE_A_ID \
  --name "aws-example-ami" \
  --description "AMI for aws example" \
  --tag-specifications \
    'ResourceType=image,Tags=[{Key=Name, Value=aws-example-ec2-ami}]'
```
## Describe AMI Status
```
aws ec2 describe-images \
  --filters "Name=tag:Name,Values=aws-example-ec2-ami" \
  --query "Images[].State"
```
## Describe AMI ImageID
```
AMI_ID=$(aws ec2 describe-images \
  --filters "Name=tag:Name,Values=aws-example-ec2-ami" \
  --query "Images[].ImageId" \
  --output text)
echo $AMI_ID
```

# ELB
## Create Security Group for ALB
```
aws ec2 create-security-group \
  --description "Secuerity group for aws example alb" \
  --group-name "aws-example-alb-sg" \
  --vpc-id $VPC_ID \
  --tag-specifications \
    'ResourceType=security-group,Tags=[{Key=Name, Value=aws-example-alb-sg}]'
```
## Describe Security Group
```
SECURITY_GROUP_FOR_ALB=$(aws ec2 describe-security-groups \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-alb-sg" \
  --query "SecurityGroups[].[GroupId]" \
  --output text)
echo $SECURITY_GROUP_FOR_ALB
```
```
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_FOR_ALB \
  --protocol tcp \
  --port 80 \
  --cidr $LOCAL_GLOBAL_IP'/32'
```
```
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_FOR_EC2 \
  --protocol tcp \
  --port 80 \
  --source-group $SECURITY_GROUP_FOR_ALB
```

## Create ALB
```
aws elbv2 create-load-balancer \
  --name aws-example-alb \
  --subnets $SUBNET_PUBLIC_AZ_A_ID $SUBNET_PUBLIC_AZ_C_ID \
  --security-group $SECURITY_GROUP_FOR_ALB \
  --tags Key=Name,Value=aws-example-alb
```
## Describe ALB
```
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --names aws-example-alb \
  --query LoadBalancers[].[LoadBalancerArn] \
  --output text)
echo $ALB_ARN
```

## Create Target Group
```
aws elbv2 create-target-group \
  --name aws-example-alb-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --health-check-interval-seconds 10 \
  --health-check-timeout-seconds 3 \
  --healthy-threshold-count 2 \
  --tag Key=Name,Value=aws-example-alb-tg
 ```
## Describe Target Group
```
ALB_TG_ARN=$(aws elbv2 describe-target-groups \
  --name aws-example-alb-tg \
  --query TargetGroups[].[TargetGroupArn] \
  --output text)
echo $ALB_TG_ARN
```
## Register targets
```
aws elbv2 register-targets \
  --target-group-arn $ALB_TG_ARN \
  --targets Id=$EC2_INSTANCE_A_ID Id=$EC2_INSTANCE_C_ID
```

## Create Lisner
```
aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$ALB_TG_ARN
```
## Get DNSName
```
ALB_DNS=$(aws elbv2 describe-load-balancers \
  --names aws-example-alb \
  --query LoadBalancers[].[DNSName] \
  --output text)
echo $ALB_DNS
```

# EIP
## Create EIP
```
aws ec2 allocate-address \
  --tag-specifications \
  'ResourceType=elastic-ip,Tags=[{Key=Name, Value=aws-example-eip-1}]' && \
aws ec2 allocate-address \
  --tag-specifications \
  'ResourceType=elastic-ip,Tags=[{Key=Name, Value=aws-example-eip-2}]'
```
## Describe EIP
```
EIP_1_ID=$(aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=aws-example-eip-1" \
  --query Addresses[].[AllocationId] \
  --output text) && \
EIP_2_ID=$(aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=aws-example-eip-2" \
  --query Addresses[].[AllocationId] \
  --output text)
echo $EIP_1_ID
echo $EIP_2_ID
```
## Attach EIP to Instance
```
aws ec2 associate-address \
  --instance-id $EC2_INSTANCE_A_ID \
  --allocation-id $EIP_1_ID && \
aws ec2 associate-address \
  --instance-id $EC2_INSTANCE_C_ID \
  --allocation-id $EIP_2_ID
```
## Check EIP and Instance Associations
```
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=aws-example-eip-1" \
  --query "Addresses[].[InstanceId,PublicIp]" \
  --output text && \
aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=aws-example-eip-2" \
  --query "Addresses[].[InstanceId,PublicIp]" \
  --output text
```

# Auto Scalling
## Create Launch Template json
```
vim lanch-template.json
```
```
{
    "IamInstanceProfile": {
        "Name": "aws-example-ec2-instance-profile"
    },
    "ImageId": "ami-XXXXXXXXXXXXXXXXX",
    "InstanceType": "t3.micro",
    "BlockDeviceMappings": [
        {
            "DeviceName": "/dev/xvda",
            "Ebs": {
                "VolumeSize": 8,
                "DeleteOnTermination": true,
                "VolumeType": "gp3"
            }
        }
    ],
    "SecurityGroupIds": [
        "sg-XXXXXXXXXXXXXXXXX"
    ],
    "TagSpecifications": [
        {
            "ResourceType": "instance",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "aws-asg-instance"
                }
            ]
        }
    ]
}
```
## Create Launch Template
```
aws ec2 create-launch-template \
  --launch-template-name aws-example-template \
  --launch-template-data file://lanch-template.json
```
## Describe Launch Template
```
LAUNCH_TEMPLATES_ID=$(aws ec2 describe-launch-templates \
  --launch-template-names aws-example-template \
  --query "LaunchTemplates[].LaunchTemplateId" \
  --output text)
echo $LAUNCH_TEMPLATES_ID
```

## Create Auto Scalling Group
```
aws autoscaling create-auto-scaling-group \
  --launch-template LaunchTemplateId=$LAUNCH_TEMPLATES_ID,Version='$Latest' \
  --auto-scaling-group-name aws-example-asg \
  --target-group-arns $ALB_TG_ARN \
  --min-size 1 \
  --desired-capacity 2 \
  --max-size 2 \
  --vpc-zone-identifier $SUBNET_PUBLIC_AZ_A_ID,$SUBNET_PUBLIC_AZ_C_ID
```
## Create Auto Scalling Group
```
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names aws-example-asg \
  --output table
```
## Update Auto Scalling Group
### Scale UP
```
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name aws-example-asg \
  --max-size 5 \
  --desired-capacity 5
```
### Scale DOWN
```
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name aws-example-asg \
  --max-size 2 \
  --min-size 1 \
  --desired-capacity 2
```
```
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name aws-example-asg \
  --max-size 0 \
  --min-size 0 \
  --desired-capacity 0
```

# RDS
## Create Subnet Group
```
aws rds create-db-subnet-group \
  --db-subnet-group-name aws-example-subnet-group \
  --db-subnet-group-description "Rds subnet group for aws example" \
  --subnet-ids '["subnet-XXXXXXXXXXXXXXXXX","subnet-XXXXXXXXXXXXXXXXX"]'
```
## Describe Subnet Group
```
aws rds describe-db-subnet-groups \
  --db-subnet-group-name aws-example-subnet-group \
  --output table
```
## Create Security Group
```
aws ec2 create-security-group \
  --description "Security group for aws example aurora" \
  --group-name "aws-example-aurora-sg" \
  --vpc-id $VPC_ID \
  --tag-specifications \
  'ResourceType=security-group,Tags=[{Key=Name, Value=aws-example-aurora-sg}]'
```
## Describe Security Group
```
SECURITY_GROUP_FOR_AURORA=$(aws ec2 describe-security-groups \
  --filters "Name=tag-key,Values=Name" "Name=tag-value,Values=aws-example-aurora-sg" \
  --query "SecurityGroups[].[GroupId]" \
  --output text)
echo $SECURITY_GROUP_FOR_AURORA
```
## Add Security Group Rules
```
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_FOR_AURORA \
  --protocol tcp \
  --port 3306 \
  --source-group $SECURITY_GROUP_FOR_EC2
```
## Create Aurora Cluster
```
aws rds create-db-cluster \
  --db-cluster-identifier aws-example-aurora-cluster \
  --engine aurora-mysql \
  --engine-version 8.0.mysql_aurora.3.01.0 \
  --master-username ExampleUser \
  --master-user-password ExamplePassword \
  --db-subnet-group-name aws-example-subnet-group \
  --vpc-security-group-ids $SECURITY_GROUP_FOR_AURORA \
  --tags "Key=Name,Value=aws-example-aurora-cluster"
```
## Describe Aurora Cluster
```
AURORA_CLUSTER=$(aws rds describe-db-clusters \
  --filters "Name=db-cluster-id,Values=aws-example-aurora-cluster" \
  --query "DBClusters[].[DBClusterIdentifier]" \
  --output text)
echo $AURORA_CLUSTER
```
## Describe Aurora Cluster Endpoint
```
AURORA_WRITER_ENDPOINT=$(aws rds describe-db-clusters \
  --filters "Name=engine,Values=aurora-mysql" \
  --query "DBClusters[].[Endpoint]" \
  --output text)
AURORA_READER_ENDPOINT=$(aws rds describe-db-clusters \
  --filters "Name=engine,Values=aurora-mysql" \
  --query "DBClusters[].[ReaderEndpoint]" \
  --output text)
echo $AURORA_WRITER_ENDPOINT
echo $AURORA_READER_ENDPOINT
```
## Show Available Engine Versions
```
aws rds describe-orderable-db-instance-options \
  --engine aurora-mysql \
  --query 'OrderableDBInstanceOptions[]. 
   [DBInstanceClass,StorageType,Engine,EngineVersion]' \
  --output table \
  --region ap-northeast-1
```
## Create DB Instance
```
aws rds create-db-instance \
  --db-instance-identifier aws-example-aurora-instance-1 \
  --db-cluster-identifier aws-example-aurora-cluster \
  --engine aurora-mysql \
  --db-instance-class db.t4g.medium \
  --availability-zone ap-northeast-1a \
  --tags "Key=Name,Value=aws-example-aurora-instance-1a" && \
aws rds create-db-instance \
  --db-instance-identifier aws-example-aurora-instance-2 \
  --db-cluster-identifier aws-example-aurora-cluster \
  --engine aurora-mysql \
  --db-instance-class db.t4g.medium \
  --availability-zone ap-northeast-1c \
  --tags "Key=Name,Value=aws-example-aurora-instance-1c"
```
## Describe DB Instance
```
DB_INSTANCE_1=$(aws rds describe-db-instances \
  --filters "Name=db-instance-id,Values=aws-example-aurora-instance-1" \
  --query "DBInstances[].[DBInstanceIdentifier]" \
  --output text) && \
DB_INSTANCE_2=$(aws rds describe-db-instances \
  --filters "Name=db-instance-id,Values=aws-example-aurora-instance-2" \
  --query "DBInstances[].[DBInstanceIdentifier]" \
  --output text)
echo $DB_INSTANCE_1
echo $DB_INSTANCE_2
```
## Connect from EC2 Instance to RDS Instance
```
mysql -u ExampleUser -p -h $AURORA_WRITER_ENDPOINT
mysql -u ExampleUser -p -h $AURORA_READER_ENDPOINT
```

# Delete resource
## Delete RDS
```
aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_1
aws rds delete-db-instance --db-instance-identifier $DB_INSTANCE_2
aws rds delete-db-cluster --db-cluster-identifier $AURORA_CLUSTER --skip-final-snapshot
aws rds delete-db-subnet-group --db-subnet-group-name aws-example-subnet-group
```
## Delete ALB
```
aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN
aws elbv2 delete-target-group --target-group-arn $ALB_TG_ARN
```
## Delete EC2
```
aws ec2 terminate-instances --instance-ids $EC2_INSTANCE_A_ID
aws ec2 terminate-instances --instance-ids $EC2_INSTANCE_C_ID
```
## Delete EIP
```
aws ec2 release-address --allocation-id $EIP_1_ID
aws ec2 release-address --allocation-id $EIP_2_ID
 aws ec2 deregister-image --image-id $AMI_ID
```
## Delete Auto Scaling Group
```
aws autoscaling update-auto-scaling-group \
  --auto-scaling-group-name aws-example-asg \
  --max-size 0 \
  --min-size 0 \
  --desired-capacity 0
aws autoscaling delete-auto-scaling-group --auto-scaling-group-name aws-example-asg
aws ec2 delete-launch-template --launch-template-id $LAUNCH_TEMPLATES_ID
```
## Delete Security Group
```
aws ec2 delete-security-group --group-id $SECURITY_GROUP_FOR_EC2
aws ec2 delete-security-group --group-id $SECURITY_GROUP_FOR_ALB
aws ec2 delete-security-group --group-id $SECURITY_GROUP_FOR_AURORA
aws ec2 detach-internet-gateway --internet-gateway-id $IGW_ID --vpc-id $VPC_ID
```
## Delete VPC
```
aws ec2 delete-subnet --subnet-id $SUBNET_PUBLIC_AZ_A_ID
aws ec2 delete-subnet --subnet-id $SUBNET_PUBLIC_AZ_C_ID
aws ec2 delete-subnet --subnet-id $SUBNET_PRIVATE_AZ_A_ID
aws ec2 delete-subnet --subnet-id $SUBNET_PRIVATE_AZ_C_ID
aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_PUBLIC_ID
aws ec2 delete-route-table --route-table-id $ROUTE_TABLE_PRIVATE_ID
aws ec2 delete-vpc --vpc-id $VPC_ID
```
## Delete IAM
```
 aws iam remove-role-from-instance-profile --instance-profile-name aws-example-ec2-instance-profile --role-name aws-example-ec2-role
 aws iam delete-instance-profile --instance-profile-name aws-example-ec2-instance-profile
 aws iam detach-role-policy --role-name aws-example-ec2-role --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore
 aws iam delete-role --role-name aws-example-ec2-role
```