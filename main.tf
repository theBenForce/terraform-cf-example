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
  schema              = <<EOF
  schema {
    query: Query
  }

  type Query {
    accounts: [Account!]!
  }

  type Account {
    id: Int!
    name: String!
  }
EOF
}

output "appsync_api" {
  value = aws_appsync_graphql_api.graphql.uris["GRAPHQL"]
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

resource "aws_secretsmanager_secret" "secret" {
  name = "test-secret"
}

resource "aws_secretsmanager_secret_version" "secret_val" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = <<-EOF
  {
    "username": "master",
    "database": "new_test",
    "engine": "aurora-postgresql",
    "port": 5432,
    "host": "localhost",
    "password": "password"
  }
  EOF
}

resource "aws_cloudformation_stack" "rds_datasource_bridge" {
  name = "rds-datasource-bridge"

  depends_on = [aws_appsync_graphql_api.graphql, aws_rds_cluster.postgresql]

  parameters = {
    ApiId               = aws_appsync_graphql_api.graphql.id
    ServiceRoleArn      = aws_iam_role.appsync.arn
    AwsSecretStoreArn   = aws_secretsmanager_secret.secret.arn
    DatabaseName        = "new_test"
    DbClusterIdentifier = aws_rds_cluster.postgresql.arn
    DataSourceName      = "rds"
  }

  template_body = <<EOF
AWSTemplateFormatVersion: "2010-09-09"
Parameters:
  ApiId:
    Type: String
  ServiceRoleArn:
    Type: String
  AwsSecretStoreArn:
    Type: String
  DatabaseName:
    Type: String
  DbClusterIdentifier:
    Type: String
  DataSourceName:
    Type: String
Resources:
  RdsDataSource:
    Type: AWS::AppSync::DataSource
    Properties: 
      ApiId: { "Ref": "ApiId" }
      Name: { "Ref": "DataSourceName" }
      RelationalDatabaseConfig: 
        RdsHttpEndpointConfig:
          AwsRegion: us-east-1
          AwsSecretStoreArn: { "Ref": "AwsSecretStoreArn" }
          DatabaseName: { "Ref": "DatabaseName" }
          DbClusterIdentifier: { "Ref": "DbClusterIdentifier" }
        RelationalDatabaseSourceType: RDS_HTTP_ENDPOINT
      ServiceRoleArn: { "Ref": "ServiceRoleArn" }
      Type: RELATIONAL_DATABASE
EOF
}



resource "aws_rds_cluster" "postgresql" {
  cluster_identifier      = "test-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "10.12"
  engine_mode             = "serverless"
  database_name           = "new_test"
  master_username         = "master"
  master_password         = "password"
  port                    = 5432
  backup_retention_period = 3
  preferred_backup_window = "07:28-07:58"
  skip_final_snapshot     = true
  enable_http_endpoint    = true
  scaling_configuration {
    auto_pause     = false
    max_capacity   = 8
    min_capacity   = 4
    timeout_action = "RollbackCapacityChange"
  }
}

resource "aws_appsync_resolver" "resolver" {
  api_id      = aws_appsync_graphql_api.graphql.id
  type        = "Query"
  field       = "accounts"
  data_source = "rds"
  kind        = "UNIT"

  depends_on = [aws_cloudformation_stack.rds_datasource_bridge]

  request_template = <<EOF
#set($sql = $util.toJson("
SELECT
  account_id as id,
  account_name as name
FROM account"))

{
  "version": "2018-05-29",
  "statements": [$sql],
  "variableMap": {}
}
EOF

  response_template = <<EOF
#set($sqlResults = $util.rds.toJsonObject($ctx.result)[0])

$util.toJson($sqlResults)
EOF
}
