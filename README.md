Terraform CF Example
------

This project provides an example terraform setup that fails to deploy to localstack
with the following error:

```bash
module.apigateway_data_source.aws_cloudformation_stack.data_source: Creating...
module.apigateway_data_source.aws_cloudformation_stack.data_source: Still creating... [10s elapsed]

Error: error waiting for CloudFormation Stack creation: ValidationError: Stack with id arn:aws:cloudformation:us-east-1:000000000000:stack/apigateway-datasource-bridge/1ca27c03 does not exist
        status code: 400, request id: 8eb7b0ac
```

But if I run `aws cloudformation list-stacks --endpoint-url=http://localhost:4566`,
I can see that the stack was created:

```json
{
    "StackSummaries": [
        {
            "StackId": "arn:aws:cloudformation:us-east-1:000000000000:stack/apigateway-datasource-bridge/1ca27c03",
            "StackName": "apigateway-datasource-bridge",
            "CreationTime": "2020-12-30T15:07:28.515000+00:00",
            "StackStatus": "CREATE_COMPLETE"
        }
    ]
}
```