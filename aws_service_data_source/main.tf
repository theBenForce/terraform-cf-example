

output "name" {
  value = aws_cloudformation_stack.data_source.outputs["Name"]
}

output "policy_arn" {
  value = aws_iam_policy.datasource_policy.arn
}



resource "aws_iam_policy" "datasource_policy" {
  name = "${var.service_name}-datasource-policy"
  path = "/cl/app/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "${var.service_name}:*"
      ],
      "Effect": "Allow",
      "Resource": [ "*" ]
    }
  ]
}
EOF
}

resource "aws_cloudformation_stack" "data_source" {
  name = "${var.service_name}-datasource-bridge"

  parameters = {
    ApiId          = var.api_id
    ServiceRoleArn = var.role_arn
    SigningRegion  = var.region
    Endpoint       = "https://${var.service_name}.${var.region}.amazonaws.com/"
    DataSourceName = "${var.service_name}_DataSource"
    SigningService = var.service_name
  }

  template_body = <<EOF
AWSTemplateFormatVersion: "2010-09-09"
Parameters:
  ApiId:
    Type: String
  ServiceRoleArn:
    Type: String
  Endpoint:
    Type: String
  SigningRegion:
    Type: String
  SigningService:
    Type: String
  DataSourceName:
    Type: String
Resources:
  AwsServiceDataSource:
    Type: AWS::AppSync::DataSource
    Properties:
      ApiId: { "Ref": "ApiId" }
      Name: { "Ref": "DataSourceName" }
      ServiceRoleArn: { "Ref": "ServiceRoleArn" }
      Type: HTTP
      HttpConfig:
        Endpoint: { "Ref": "Endpoint" }
        AuthorizationConfig:
          AuthorizationType: "AWS_IAM"
          AwsIamConfig:
            SigningRegion: { "Ref": "SigningRegion" }
            SigningServiceName: { "Ref": "SigningService" }
Outputs:
  Name:
    Value: { "Ref": "DataSourceName" }
EOF
}
