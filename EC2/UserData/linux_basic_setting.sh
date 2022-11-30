#cloud-config
password: [Enter password]
chpasswd: { expire: False }
ssh_pwauth: True


#!/bin/bash
## Package Update
apt-get update -y
apt-get upgrade -y
apt-get autoremove -y
apt-get clean -y
apt-get autoclean -y
apt-get check -y

## Language Settings
localectl set-locale LANG=ja_JP.utf8
source /etc/locale.conf

## Time setting
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

## Host Information Settings
hostnamectl set-hostname <hostname>
/etc/init.d/networking restart

## User Creation
USERNAME=<username>
PASSWORD=<password>
echo "${PASSWORD}" | passwd --stdin ${USERNAME}
usermod -G <Group Name1>,<Group Name2>,<Group Name3> ${USERNAME}
# Example(EC2)：usermod -G ec2-user,adm,wheel,systemd-journal ${USERNAME}
# Example(Lightsail(WordPress))：sudo usermod -G bitnami,chibiharu,adm,dialout,cdrom,floppy,sudo,audio,dip,video,plugdev,netdev,bitnami-admins ${USERNAME} 
sed -i -e '$ a ${USERNAME} ALL=(ALL)    NOPASSWD:ALL' /etc/sudoers

## Password Login Settings
sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd