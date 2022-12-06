***
# Setup for amazon-linux

## Install Docker
```
sudo yum update -y
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
docker info
```

## Shell Variable Settings
```
region=
aws_account_id=
docker_image_name=
Container_name=
repository_name=
cluster_name=
service_name=
service_subnets=
service_securityGroups=
task_definition_name=
```
***
# Docker

## Create Docker file
> vim Dockerfile
```
FROM ubuntu:18.04
​
# Install dependencies
RUN apt-get update && \
 apt-get -y install apache2
​
# Install apache and write hello world message
RUN echo 'Hello World!' > /var/www/html/index.html
​
# Configure apache
RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
 echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
 echo 'mkdir -p /var/lock/apache2' >> /root/run_apache.sh && \ 
 echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \ 
 chmod 755 /root/run_apache.sh
​
EXPOSE 80
​
CMD /root/run_apache.sh
```

## Whitespace removal in Docker files
```
sed -i "s/$(echo -ne '\u200b')//g" Dockerfile
```

## docker build
```
docker build -t $docker_image_name .
docker images
```

## docker run
```
docker run -d -p 80:80 --name $Container_name $docker_image_name
docker ps
curl localhost:80
```

## Connect to Docker with Bash
```
docker exec -i -t $Container_name bash
exit
```

***
# ECR

## ECR Registry Registration
```
aws ecr get-login-password --region $region | docker login --username AWS \
    --password-stdin $aws_account_id.dkr.ecr.$region.amazonaws.com
```
## ECR Registry Information Output
```
aws ecr describe-registry
```

## ECR Creation
```
aws ecr create-repository \
    --repository-name $repository_name \
    --image-scanning-configuration scanOnPush=true \
    --region $region

```
## describe repositories
```
aws ecr describe-repositories
```
## Push Docker image to ECR
```
docker tag $docker_image_name:latest $aws_account_id.dkr.ecr.$region.amazonaws.com/$repository_name
docker push $aws_account_id.dkr.ecr.$region.amazonaws.com/$repository_name
```
## describe Docker image
```
aws ecr describe-images --repository-name $repository_name
```

## Pull Docker image from ECR
```
docker pull $aws_account_id.dkr.ecr.$region.amazonaws.com/$repository_name:latest
```

***
# ECS Forgate

## Creating IAM Roles for Task Definition
### IAM Policy Creation

> vim $HOME/ecs-tasks-trust-policy.json
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### IAM Role Creation
```
aws iam create-role \
      --role-name ecsTaskExecutionRole \
      --assume-role-policy-document file://$HOME/ecs-tasks-trust-policy.json
```
### AmazonECSTaskExecutionRolePolicy Policy Attach
```
aws iam attach-role-policy \
      --role-name ecsTaskExecutionRole \
      --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```


## Create an ECS cluster
```
aws ecs create-cluster --cluster-name $cluster_name
```

## describe ECS cluster
```
aws ecs describe-clusters
```

## Register Linux Task Definitions
```
mkdir $HOME/tasks
```
> vim $HOME/tasks/fargate-task.json
```
{
    "family": "< task definition name >", 
    "networkMode": "awsvpc", 
    "containerDefinitions": [
        {
            "name": "< container name>", 
            "image": "< ecr image >", 
            "portMappings": [
                {
                    "containerPort": 80, 
                    "hostPort": 80, 
                    "protocol": "tcp"
                }
            ], 
            "essential": true 
        }
    ],
    "executionRoleArn": "`< ecs executionRole >`",
    "requiresCompatibilities": [
        "FARGATE"
    ], 
    "cpu": "256", 
    "memory": "512"
}
```
```
aws ecs register-task-definition --cli-input-json file://$HOME/tasks/fargate-task.json
aws ecs list-task-definitions
```

## Create a service
### private
```
aws ecs create-service --cluster $cluster_name --service-name $service_name --task-definition $task_definition_name:1 \
    --desired-count 1 --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=$service_subnets,securityGroups=$service_securityGroups}"
```
### public
```
aws ecs create-service --cluster $cluster_name --service-name $service_name --task-definition sample-fargate:1 \
    --desired-count 1 --launch-type "FARGATE" \
    --network-configuration "awsvpcConfiguration={subnets=$service_subnets,securityGroups=$service_securityGroups,assignPublicIp=ENABLED}"
```

## List services
```
aws ecs list-services --cluster $cluster_name
```

## Get details of running services
```
aws ecs describe-services --cluster $cluster_name --services $service_name
```

## Task ARN acquisition
```
aws ecs list-tasks --cluster $cluster_name --service $service_name
```

## ENI ID Acquisition
```
aws ecs describe-tasks --cluster $cluster_name --tasks < arn:aws:ecs:us-east-1:XXXXXXXXXXXX:task/service/XXXXXX >
```

##  IP address acquisition
```
aws ec2 describe-network-interfaces --network-interface-id  < eni-XXXXXXXXXXXXXXXXXX >
```

## clean up
### Delete service
```
aws ecs delete-service --cluster $cluster_name --service $service_name --force
```

### Delete Cluster
```
aws ecs delete-cluster --cluster $cluster_name
```

### Unsubscribe a task definition
```
aws ecs deregister-task-definition --task-definition $task_definition_name:1
```

## Delete ECR's Docker image
```
aws ecr batch-delete-image \
      --repository-name $repository_name \
      --image-ids imageTag=latest \
      --region $region
```
## ECR repository deletion
```
aws ecr delete-repository \
      --repository-name $repository_name \
      --force \
      --region $region
```