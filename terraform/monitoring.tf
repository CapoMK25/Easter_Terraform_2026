# --- MONITORING ---
# Removed for free tier:
# - aws_kms_key (customer-managed): $1/month per key + API call charges
# - aws_kms_alias: tied to the removed key
#
# CloudWatch Logs free tier: 5 GB ingestion, 5 GB storage per month
# CloudWatch Alarms free tier: 10 alarm metrics per month
# CloudWatch Dashboards free tier: 3 dashboards with up to 50 metrics per month

# --- 1. LOGS ---
# Reduced retention to 7 days to stay comfortably within 5 GB storage free tier
# Removed KMS encryption - logs are encrypted at rest by default using AWS-managed keys

resource "aws_cloudwatch_log_group" "demo_log_group" {
  name              = "easterterraform-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "demo_stream" {
  name           = "demo-stream"
  log_group_name = aws_cloudwatch_log_group.demo_log_group.name
}

# --- 2. ALARMS ---
# Free tier: 10 alarm metrics/month - this uses 1

resource "aws_cloudwatch_metric_alarm" "s3_4xx_alarm" {
  alarm_name          = "S3WebsiteErrorAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4xxErrors"
  namespace           = "AWS/S3"
  period              = "60"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alarm if S3 bucket returns too many 404s"

  dimensions = {
    BucketName = "regional-map-2024-website"
    FilterId   = "EntireBucket"
  }
}

# --- 3. DASHBOARD ---
# Free tier: 3 dashboards - this uses 1

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "EasterTerraform-S3-Health"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0, "y": 0, "width": 12, "height": 6,
      "properties": {
        "metrics": [
          ["AWS/S3", "4xxErrors", "BucketName", "regional-map-2024-website"]
        ],
        "period": 300,
        "stat": "Sum",
        "region": "eu-north-1",
        "title": "S3 Website 4xx Errors"
      }
    }
  ]
}
EOF
}
