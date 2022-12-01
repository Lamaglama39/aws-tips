#!/bin/bash
## NFS
# Variable setting
file_system_id_01=fs-123456789abcdefg
efs_directory=/mnt/efs
aws_region=ap-northeast-1

#nfs-utils installation
sudo yum -y install nfs-utils

# Directory Creation,Edit /etc/fstab
mkdir -p $efs_directory
echo "${file_system_id_01}.efs.${aws_region}.amazonaws.com:/ ${efs_directory} nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab

# mount
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${file_system_id_01}.efs.${aws_region}.amazonaws.com:/ ${efs_directory}


#!/bin/bash
## Helper
# Variable setting
file_system_id_01=fs-123456789abcdefg
efs_directory=/mnt/efs

#efs-utils installation
sudo yum install -y amazon-efs-utils

# Directory Creation,Edit /etc/fstab
mkdir -p $efs_directory
echo "${file_system_id_01}:/ ${efs_directory} efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
## use iam-role
#<file-system-id>:/ <efs-mount-point> efs _netdev,noresvport,tls,iam 0 0
## use profile
#<file-system-id>:/ <efs-mount-point> efs _netdev,noresvport,tls,iam,awsprofile=<namedprofile> 0 0
# use access point
#<file-system-id>:/ <efs-mount-point> efs _netdev,noresvport,tls,iam,accesspoint=<access-point-id> 0 0

# mount
mount -a -t efs defaults