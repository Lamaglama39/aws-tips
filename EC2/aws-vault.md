# aws-vault
## config file
```
vim .aws/config
```
```
[default]
region=ap-northeast-1
```

## install for brew
```
brew install  aws-vault
```
## install for wget
```
AWS_VAULT_VERSION="v6.6.2" && \
wget -O aws-vault "https://github.com/99designs/aws-vault/releases/download/${AWS_VAULT_VERSION}/aws-vault-linux-amd64"
```
```
sudo mv aws-vault /usr/bin/ && sudo chmod +x /usr/bin/aws-vault
aws-vault --version
```
## setting keys
```
aws-vault --backend=file add USERNAME
aws-vault ls --backend=file
```

### No need to specify backend option when executing commands
```
echo 'export AWS_VAULT_BACKEND=file' >> $HOME/.bashrc
```
### Automatic Password Setting
```
echo "export AWS_VAULT_FILE_PASSPHRASE=PASSWORD" >> $HOME/.bashrc
aws-vault exec USERNAME -- aws sts get-caller-identity
aws-vault exec USERNAME -- env | grep AWS
```