# DYNAMODB TABLE
# Free tier: 25 GB storage, 25 WCU, 25 RCU (provisioned mode)
# OR PAY_PER_REQUEST with 25 GB storage and generous on-demand request limits
# Using PAY_PER_REQUEST for simplicity and to avoid capacity over-provisioning

# Removed for free tier:
# - point_in_time_recovery: NOT free tier (charged per GB of backup storage)
# - server_side_encryption with customer KMS key: customer KMS keys cost $1/month each
#   (AWS-owned keys are used by default when server_side_encryption block is omitted, and they are free)

resource "aws_dynamodb_table" "easter_terraform_2026_table" {
  name         = "easter_terraform_2026-table"
  billing_mode = "PAY_PER_REQUEST"

  # Partition Key (HASH) and Sort Key (RANGE)
  hash_key  = "PK"
  range_key = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  tags = {
    Environment = var.environment
    Project     = var.easter_terraform_prefix
  }
}
