# Installing AWS CLI
```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

# Update existing AWS CLI
```
./aws/install -i /usr/local/aws-cli -b /usr/local/bin
```

# Enable AWS CLI command completion
```
complete -C aws_completer aws
echo 'complete -C aws_completer aws' >> $HOME/.bash_profile
```