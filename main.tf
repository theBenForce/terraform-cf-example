provider "aws" {
  access_key                  = "mock_access_key"
  region                      = "us-east-1"
  s3_force_path_style         = true
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway       = "http://localhost:4566"
    appsync          = "http://localhost:4566"
    cloudformation   = "http://localhost:4566"
    cloudwatch       = "http://localhost:4566"
    dynamodb         = "http://localhost:4566"
    elasticache      = "http://localhost:4566"
    transfer         = "http://localhost:4566"
    rds              = "http://localhost:4566"
    es               = "http://localhost:4566"
    iam              = "http://localhost:4566"
    lambda           = "http://localhost:4566"
    route53          = "http://localhost:4566"
    s3               = "http://localhost:4566"
    secretsmanager   = "http://localhost:4566"
    ses              = "http://localhost:4566"
    sns              = "http://localhost:4566"
    sqs              = "http://localhost:4566"
    ssm              = "http://localhost:4566"
    stepfunctions    = "http://localhost:4566"
    sts              = "http://localhost:4566"
    cognitoidp       = "http://localhost:4566"
    cognitoidentity  = "http://localhost:4566"
    ec2              = "http://localhost:4566"
    firehose         = "http://localhost:4566"
    codecommit       = "http://localhost:4566"
    cloudwatchevents = "http://localhost:4566"
    cloudwatchlogs   = "http://localhost:4566"
  }
}

data "aws_region" "current" {}

resource "aws_appsync_graphql_api" "graphql" {
  authentication_type = "AWS_IAM"
  name                = "graphql-api"
  schema              = ""
}

resource "aws_iam_role" "appsync" {
  name = "appsync_service_role"
  path = "/cl/app/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

module "apigateway_data_source" {
  source       = "./aws_service_data_source"
  service_name = "apigateway"
  api_id       = aws_appsync_graphql_api.graphql.id
  role_arn     = aws_iam_role.appsync.arn
  region       = data.aws_region.current.name
}

resource "aws_iam_role" "appsync_api_role" {
  name               = "appsync_api_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "appsync_api_role_policy" {
  name = "appsync_api_role_policy"
  role = aws_iam_role.appsync_api_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "appsync:GraphQL"
        ],
        "Effect": "Allow",
        "Resource": "${aws_appsync_graphql_api.graphql.arn}/*"
      }
    ]
  }
  EOF
}
