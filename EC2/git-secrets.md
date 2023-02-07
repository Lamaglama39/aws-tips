# git secrets
## install for brew
```
brew update
brew install git-secrets
which git-secrets
```

## install for git clone
```
git clone https://github.com/awslabs/git-secrets
cd git-secrets
sudo make install
which git-secrets
```
## install for curl
```
curl -O https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets
chmod +x git-secrets
sudo mv -i -i git-secrets /usr/bin/

which git-secrets
```

# git secrets config
## Set standard pattern for AWS accessories
```
git secrets --register-aws --global
```
## Scan for anything other than gitfile
```
git secrets --scan --no-index
```
## Manual Scanning
```
git secrets --scan
```
## Automatic scan (at commit)
```
git secrets --install 
```
## Exception setting
```
git secrets --add --allowed AllowValue
```