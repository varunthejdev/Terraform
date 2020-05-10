# Lambda to register New AWS accounts to Redlock  

## Introduction

As part of the aws account creation pipeline, newly created AWS accounts need to be registered to the Redlock Security Monitoring tool.

As part of this implementation, We need a Redlock user credentials, which are used to get the token
for REST API call operations. Below are the three major tasks in the lambda function.

1. Store the Redlock user credentials in AWS System Manager.
2. POST operation by using user credentials to get the token for next REST calls.
3. Read the AccountID from event and run POST operation to add AWS AccountID to Redlock.

## What this function does?

### In-line policy for the role used by Redlock in Target accounts

 Redlock needs a readonly-access role in target accounts to register and automatically discovers the new and existing resources in the cloud account. This role uses in built SecurityAudit policy and below custom inline policy.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "sqs:SendMessage",
                "sns:List*",
                "sns:Get*",
                "secretsmanager:List*",
                "secretsmanager:Describe*",
                "rds:ListTagsForResource",
                "logs:Get*",
                "logs:FilterLogEvents",
                "logs:Describe*",
                "kinesis:List*",
                "kinesis:Describe*",
                "inspector:List*",
                "inspector:Describe*",
                "iam:SimulatePrincipalPolicy",
                "iam:SimulateCustomPolicy",
                "guardduty:List*",
                "guardduty:Get*",
                "glacier:List*",
                "glacier:Get*",
                "elasticmapreduce:List*",
                "elasticmapreduce:Describe*",
                "elasticfilesystem:Describe*",
                "elasticache:List*",
                "eks:List*",
                "eks:Describe*",
                "dynamodb:DescribeTable",
                "ds:Describe*",
                "cloudtrail:LookupEvents",
                "cloudtrail:GetEventSelectors",
                "cloudsearch:Describe*",
                "appstream:Describe*",
                "apigateway:GET",
                "acm:List*"
            ],
            "Resource": "*"
        }
    ]
}

We store the Redlock user credentials in AWS System Manager and retrieve them through boto client call.  

```python
 client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )
```

Redlock has Account groups which we will be used to categorize the groups based on account type and access privilages within redlock. Primary we are going to use below two account groups for any aws accounts:

 Core: For Core Accounts.
 Default AWS Account Provisioning Group: This is for all Accounts other than Core Accounts. 

Snippet from POST Operation call to get the token by using user credentials from secret manager:

```python
 token = resp["token"]
        account_payload = {
        "accountId": account_id,
        "enabled": True,
        "externalId": "tlz-redlock",
        "groupIds": [ "5fef1566-d747-41be-9363-f3ef69dbdca3" ],
        "name": account_alias,
        "roleArn": f"arn:aws:iam::{account_id}:role/tlzRedlockReadOnly"
        }
        headers = {"x-redlock-auth" : token, "Content-Type" : "application/json"}
        print(f"Token : {token}")
        addaccount_r = requests.post('https://api.redlock.io/cloud/aws', headers=headers, data=json.dumps(account_payload), verify=False)
```

## Testing

Create a test event in lambda console like below and run:  

```json
{
  "AccountId": "907183237271"
}
```

## Results

If lambda function executed ok then the result REST call status is 200 and below is screenshot of account registration in Redlock

![Success](../../images/Redlock.png)

If the status code is 400, the reason could be one of the below:

duplicate_cloud_account_name/duplicate_cloud_account/invalid_account_id_format/duplicate_cloud_account_needs_upgrade

If the status code is 500 then it's a internal error.

### Additional Sources

Redlock API Reference: [Redlock API](https://api.docs.redlock.io/reference)

