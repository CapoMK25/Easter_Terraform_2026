#!/bin/bash
set -e

# --- 1. Local ENV ---
export AWS_DEFAULT_REGION=eu-north-1
export AWS_REGION=eu-north-1
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-test}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-test}

# Localstack pointer for AWS CLI and Terraform
ENDPOINT_URL="http://localstack:4566"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform"
WEBSITE_CONTENT_DIR="${WEBSITE_CONTENT_DIR:-$REPO_ROOT/regional-map-2024}"

echo "🚀 Starting 2026 Easter Terraform Deployment..."
echo "📍 Region: $AWS_DEFAULT_REGION | 🔗 Endpoint: $ENDPOINT_URL"

# --- 2. Terraform Lifecycle ---
cd "$TF_DIR"

echo "⚙️ Initializing Terraform..."
terraform init

echo "🔍 Generating Plan..."
terraform plan -out=tfplan

echo "🏗️ Applying Infrastructure..."
terraform apply -auto-approve tfplan

# --- 3. Sync regional-map-2024 here ---
echo "📤 Syncing Website Files to S3..."
if [ -d "$WEBSITE_CONTENT_DIR" ]; then
    aws --endpoint-url="$ENDPOINT_URL" s3 sync "$WEBSITE_CONTENT_DIR" s3://regional-map-2024-website/ \
        --exclude ".git/*" \
        --region "$AWS_DEFAULT_REGION"
    echo "✨ Website Sync Complete."
else
    echo "⚠️ Warning: Website directory not found at $WEBSITE_CONTENT_DIR. Skipping sync."
fi

echo "🏁 DEPLOYMENT COMPLETE!"
echo "🔗 Access your site at: http://localhost:4566/regional-map-2024-website/index.html"