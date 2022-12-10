# s3fs
## s3fs install
```
sudo amazon-linux-extras install epel
sudo yum install s3fs-fuse
```

## mount and edit /etc/fstab
```
sudo mkdir /mnt/s3fs
echo "< backet name > /mnt/s3bucket fuse.s3fs _netdev,allow_other,iam_role=auto 0 0" | sudo tee -a /etc/fstab
sudo mount -a
df -h
```

## umount
```
sudo umount /mnt/s3fs
```



# goofys
## goofys install
```
sudo curl -L https://github.com/kahing/goofys/releases/latest/download/goofys -o /usr/local/bin/goofys
sudo chmod a+x /usr/local/bin/goofys
goofys --version
```

## mount and edit /etc/fstab
```
sudo mkdir /mnt/goofys
echo "< backet name > /home/ec2-user/goofs  fuse  _netdev,allow_other,--file-mode=0666,--dir-mode=0777  0 0" | sudo tee -a /etc/fstab
sudo mount -a
df -h
```

## umount
```
fusermount -u /mnt/goofys
```