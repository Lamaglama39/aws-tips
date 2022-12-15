# Create VPC and subnets
## Create a VPC
```
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query Vpc.VpcId \
  --output text
```
## Get VPC list
```
aws ec2 describe-vpcs | jq '.Vpcs[]'
```

## Create a subnets
```
aws ec2 create-subnet \
  --vpc-id vpc-XXXXXXXX \
  --cidr-block 10.0.1.0/24
```
## Get Subnet List
```
aws ec2 describe-subnets | jq '.Subnets[]'
```
# Make the subnet public
## Create an Internet gateway
```
aws ec2 create-internet-gateway \
 --query InternetGateway.InternetGatewayId \
 --output text
```
## attach the Internet gateway to the VPC
```
aws ec2 attach-internet-gateway \
  --vpc-id vpc-XXXXXXXX \
  --internet-gateway-id igw-XXXXXXXX
```
## Create a custom route table for the VPC.
```
aws ec2 create-route-table \
  --vpc-id vpc-XXXXXXXX \
  --query RouteTable.RouteTableId \
  --output text
```
## Get RouteTable list
```
aws ec2 describe-route-tables | jq '.RouteTables[]'
```

## Create a route in the route table that points to the Internet Gateway
```
aws ec2 create-route \
  --route-table-id rtb-XXXXXXXX \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id igw-XXXXXXXX
```
## Verify that the route is created and enabled
```
aws ec2 describe-route-tables \
  --route-table-id rtb-XXXXXXXX
```

## Get the subnet ID
```
aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-XXXXXXXX" \
  --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock}"
```
## Associate a subnet to the custom route table
```
aws ec2 associate-route-table  \
  --subnet-id subnet-XXXXXXXX \
  --route-table-id rtb-XXXXXXXX
```
## Obtain public IP address automatically
```
aws ec2 modify-subnet-attribute \
  --subnet-id subnet-XXXXXXXX \
  --map-public-ip-on-launch
```

# clean up

> vim vpc_check.sh
```
#!/bin/bash
vpc=$1

aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep InternetGatewayId
aws ec2 describe-subnets --filters 'Name=vpc-id,Values='$vpc | grep SubnetId
aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc | grep RouteTableId
aws ec2 describe-network-acls --filters 'Name=vpc-id,Values='$vpc | grep NetworkAclId
aws ec2 describe-vpc-peering-connections --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
aws ec2 describe-vpc-endpoints --filters 'Name=vpc-id,Values='$vpc | grep VpcEndpointId
aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
aws ec2 describe-security-groups --filters 'Name=vpc-id,Values='$vpc | grep GroupId
aws ec2 describe-instances --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
aws ec2 describe-vpn-connections --filters 'Name=vpc-id,Values='$vpc | grep VpnConnectionId
aws ec2 describe-vpn-gateways --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
aws ec2 describe-network-interfaces --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId
```
> chmod +x vpc_delete.sh
> ./vpc_check.sh vpc-xxxxxxxxxxxxxxxxxxxx
```
aws ec2 delete-security-group --group-id sg-xxxxxxxxxxx
aws ec2 delete-network-acl --network-acl-id acl-xxxxxxxxxxx
aws ec2 delete-subnet --subnet-id subnet-xxxxxxxxxxx
aws ec2 delete-route-table --route-table-id rtb-xxxxxxxxxxx
aws ec2 detach-internet-gateway --internet-gateway-id igw-xxxxxxxxxxx --vpc-id vpc-xxxxxxxxxxx
aws ec2 delete-internet-gateway --internet-gateway-id igw-xxxxxxxxxxx
aws ec2 delete-vpc --vpc-id vpc-xxxxxxxxxxx
aws ec2 describe-vpcs --vpc-id vpc-vpc-xxxxxxxxxxx
```