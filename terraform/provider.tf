# /terraform/provider.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "eu-north-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2        = "http://localstack:4566"
    elb        = "http://localstack:4566"
    elbv2      = "http://localstack:4566"
    kms        = "http://localstack:4566"
    iam        = "http://localstack:4566"
    s3         = "http://localstack:4566"
    dynamodb   = "http://localstack:4566"
    logs       = "http://localstack:4566"
    cloudwatch = "http://localstack:4566"
  }
}