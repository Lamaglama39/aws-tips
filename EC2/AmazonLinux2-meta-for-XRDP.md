# Amazon Linux2 MetaDesktop for XRDP

## sg port
```
Allow port 22
Allow port 3389
```

## user data
```
#!/bin/bash
sudo yum -y update
sudo amazon-linux-extras install -y mate-desktop1.x
sudo bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'
sudo amazon-linux-extras install -y epel
sudo yum install -y xrdp
sudo systemctl start xrdp
sudo systemctl enable xrdp
sudo systemctl status xrdp
```

## set user password
```
sudo passwd ec2-user
```