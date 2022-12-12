***
# config
```
[profile default]
region = ap-northeast-1 
output = json 

[profile test] 
role_arn = arn:aws:iam::account_id:role/role_name
source_profile = default 
mfa_serial = arn:aws:iam::account_id:mfa/user_name
```
***
# credentials
```
[default]
aws_access_key_id = XXXXXXXXXXXXXXXX
aws_secret_access_key = XXXXXXXXXXXXXXXX
[test]
aws_access_key_id = SSSSSSSSSSSSSSSSSSSSSS
aws_secret_access_key = SSSSSSSSSSSSSSSSSSSSS
```
***

# Check current account
```
aws configure list
```
# Obtain AWS account ID only
```
aws sts get-caller-identity --output json
```
# Account Switching
```
export AWS_DEFAULT_PROFILE=test
```
***


# IAM
## Get user iam list
aws iam list-users

## Create instance profiles
aws iam create-instance-profile --instance-profile-name profilename
# Add IAM role to instance profile
aws iam add-role-to-instance-profile --instance-profile-name profilename --role-name rolename
# Attach instance profile to EC2 instance
aws ec2 associate-iam-instance-profile --iam-instance-profile Name=profilename --instance-id i-XXXXXXXXXXXX
# describe iam instance profile
aws ec2 describe-iam-instance-profile-associations --filters Name=instance-id,Values=i-XXXXXXXXXXXX

# instance profiles list
aws iam list-instance-profiles
# instance profiles delete
aws iam delete-instance-profile --instance-profile-name rolename