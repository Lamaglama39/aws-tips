# create parameter
## Store parameters (strings) in parameter store
```
aws ssm put-parameter \
  --name user \
  --type String \
  --value user.name \
  --region ap-northeast-1
```

## Store parameter (secure string) in parameter store
```
aws ssm put-parameter \
  --name password \
  --type SecureString \
  --value db.password
```

## Store parameter (string list) in parameter store
```
aws ssm put-parameter \
  --name list \
  --type StringList \
  --value value1,value2,value3
```

## Stores secure strings by specifying KMSkey
```
aws ssm put-parameter \
  --name securekey \
  --value secret_value \
  --type SecureString \
  --key-id <KeyId>
```
# Rewrite
## Rewrite parameter
```
aws ssm put-parameter \
  --name user \
  --value user.name2 \
  --type String \
  --overwrite
```

## Rewrite parameter list
```
aws ssm put-parameter \
  --name list \
  --value value4,value5 \
  --type StringList \
  --overwrite
```
# history
## Output modification history
```
aws ssm get-parameter-history \
  --name user
```

# Search parameter
## Searches for parameter names that start with the specified string
```
aws ssm describe-parameters \
    --parameter-filters "Key=Name,Option=BeginsWith,Values=user"
```

## Search for parameter names containing the specified string
```
aws ssm describe-parameters \
    --parameter-filters "Key=Name,Option=Contains,Values=user"
```

# Get value
## Obtain information on the entire parameter
```
aws ssm get-parameters \
  --name user \
  --with-decryption
```
## Obtain only strings within parameters
```
aws ssm get-parameters \
  --name user \
  --with-decryption \
  --query "Parameters[0].Value" \
  --output text
```

# Delete Parameter
```
aws ssm delete-parameter \
  --name user
```