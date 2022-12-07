# Cloud9 Creation
```
aws cloud9 create-environment-ec2 \
  --name demo-cloud9 \
  --description "demo-cloud9" \
  --instance-type t2.micro \
  --image-id resolve:ssm:/aws/service/cloud9/amis/amazonlinux-1-x86_64 \
  --region ap-northeast-1 \
  --connection-type CONNECT_SSM \
  --subnet-id subnet-XXXXXXXX \
  --owner-arn arn:aws:sts::XXXXXXXXXXXXXX:assumed-role/role_name/user_name
```