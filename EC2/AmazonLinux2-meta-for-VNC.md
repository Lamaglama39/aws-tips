# Amazon Linux2 MetaDesktop for VNC

## sg port
```
Allow port 22
Allow port 5901
```

## user data
```
#!/bin/bash
sudo yum -y update
sudo amazon-linux-extras install -y mate-desktop1.x
sudo bash -c 'echo PREFERRED=/usr/bin/mate-session > /etc/sysconfig/desktop'
sudo yum install -y tigervnc-server
```

## connect for ssh
```
vncpasswd
```
```
sudo cp /lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@.service
sudo sed -i 's/<USER>/ec2-user/' /etc/systemd/system/vncserver@.service
sudo systemctl daemon-reload
sudo systemctl enable vncserver@:1
sudo systemctl start vncserver@:1
```

## connect for VNC
```
instance IP address:5901
```