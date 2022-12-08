# Connecting to an EC2 instance
## Instance listing in tabular format
```
aws ec2 describe-instances \
  --max-items 1000\
  --query 'Reservations[].Instances[].{
     InstanceId:InstanceId,
     InstanceType:InstanceType,
     State: State.Name,
     Name:Tags[?Key==`Name`]|[0].Value,
     ASG:Tags[?Key==`aws:autoscaling:groupName`]|[0].Value
     }'\
 --output table
```
## Obtaining a list of EC2 instances and getting the ssh command to them
```
aws ec2 describe-instances \
  | jq -r '.Reservations[]?.Instances[]? | [[.Tags[]? | select(.Key == "Name").Value][0], "<<  public IP  >>    ssh ec2-user@" + .NetworkInterfaces[].Association.PublicIp + " -i ~/.ssh/key"] | @tsv' \
  | column -t -s "`printf '\t'`" &&
aws ec2 describe-instances \
  | jq -r '.Reservations[]?.Instances[]? | [[.Tags[]? | select(.Key == "Name").Value][0], "<< private IP  >>    ssh ec2-user@" + .NetworkInterfaces[].PrivateIpAddress + " -i ~/.ssh/key"] | @tsv' \
  | column -t -s "`printf '\t'`" 
```

## Obtaining a list of EC2 instances and the scp command for them
```
aws ec2 describe-instances \
  | jq -r '.Reservations[]?.Instances[]? | [[.Tags[]? | select(.Key == "Name").Value][0], "<<  public IP  >>    scp -i \"~/.ssh/key\" <filename> ec2-user@" + .NetworkInterfaces[].Association.PublicIp + ":~/ "] | @tsv' \
  | column -t -s "`printf '\t'`" &&
aws ec2 describe-instances \
  | jq -r '.Reservations[]?.Instances[]? | [[.Tags[]? | select(.Key == "Name").Value][0], "<< private IP  >>    scp -i \"~/.ssh/key\" <filename> ec2-user@" + .NetworkInterfaces[].PrivateIpAddress + ":~/ "] | @tsv' \
  | column -t -s "`printf '\t'`"
```