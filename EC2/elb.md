# ELB
# Obtain a list of InstanceId and Status associated with the ELB
aws elb describe-instance-health --load-balancer-name YOUR ELB NAME | jq '.InstanceStates[]|{InstanceId, State}'

# Upload certificate to ELB
```
aws iam upload-server-certificate --server-certificate-name monoqn-20170512 --certificate-body file://my-crt.pem --private-key file://my-key.pem --certificate-chain file://my-chain.pem
Elastic Beanstalk
ApplicationName,EnvironmentName,VersionLabel,EndpointURL,CNAMEList
aws elasticbeanstalk describe-environments | jq '.Environments[] | {ApplicationName, EnvironmentName, VersionLabel, EndpointURL, CNAME}'
```
# Get local global IP
```
curl -s ipinfo.io | jq -r '.ip'
curl ifconfig.me
curl http://checkip.amazonaws.com/
```
# Get local IP
```
ifconfig eth0 | grep inet
```