# RDS
## Obtain an RDS instance
```
aws rds describe-db-instances 
```

## Obtain RDS EndPoint and DB Instance Identifier
```
aws rds describe-db-instances | jq '.DBInstances[] |{DBInstanceIdentifier,Endpoint}'
```

## Obtain a list of DBSnapshotIdentifier and DBInstanceIdentifier of RDS Snapshot
```
aws rds describe-db-snapshots | jq '.DBSnapshots[] | {DBSnapshotIdentifier, DBInstanceIdentifier}'
```

## Obtain a list of RDS logs
```
aws rds describe-db-log-files \
  --db-instance-identifier db-name | jq '.DescribeDBLogFiles[].LogFileName'
```

## Download RDS logs
```
aws rds download-db-log-file-portion \
  --db-instance-identifier db-name \
  --region ap-northeast-1 \
  --log-file-name "slowquery/mysql-slowquery.log" \
  --output text
```

## Reset RDS Master Password
```
aws rds modify-db-instance \
  --db-instance-identifier db-name \
  --master-user-password 'xxxxxxx'
```