***
# Prerequisite
## Vscode
- AWS CLI must be available.
- Ability to use privileges equivalent to those of an Admin.

## AWS
- Cloud9 has been created.
- public IP must exist on Cloud9's EC2.



***
# vscode Config
Key creation for ssh connection.
```
cd /User/user_name/.ssh
ssh-keygen -f cloud9
```
Add Cloud9 connection point to ssh configuration file.
> vim ~/.ssh/config
```
Host cloud9
  HostName <EC2 PublicIP address>
  IdentityFile ~/.ssh/cloud9
  User ec2-user
```
Add IP address to security group.
```
curl https://checkip.amazonaws.com
aws ec2 authorize-security-group-ingress --group-id < SGID > --protocol tcp --port 22 --cidr < x.x.x.x >
```



***
# Cloud9 Config
Append the public key created by vscode.
> vim ~/.ssh/authorized/authorized_keys
```
#
# Add any additional keys below this line
#
ssh-rsa *********************************
```
Edit sshd configuration file to allow key authentication
> vim /etc/ssh/sshd_config
```
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile     .ssh/authorized_keys
```
sshd.service restart
```
which sshd
/usr/sbin/sshd
/usr/sbin/sshd -t
sudo systemctl restart sshd.service
```


***
# Connection
```
ssh -i "~/.ssh/cloud9" ec2-user@ecX-XX-XX-XX-XX.< region >.compute.amazonaws.com
```