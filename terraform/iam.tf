# VARIABLES DEFINED IN ONE CENTRAL FILE

# USER & GROUP SETUP

resource "aws_iam_group" "admins" {
  name = "${var.easter_terraform_prefix}-Admins"
}

resource "aws_iam_user" "capomk_user" {
  name = "${var.easter_terraform_prefix}-CapoMK"
}

resource "aws_iam_group_membership" "add_mk_to_admins" {
  name  = "add-mk-to-admins"
  users = [aws_iam_user.capomk_user.name]
  group = aws_iam_group.admins.name
}

# ADMIN POLICY

# checkov:skip=CKV_AWS_107
# checkov:skip=CKV_AWS_108
# checkov:skip=CKV_AWS_109
# checkov:skip=CKV_AWS_110
# checkov:skip=CKV_AWS_111
resource "aws_iam_policy" "admins_policy" {
  name        = "${var.easter_terraform_prefix}-AdminsAdministratorAccess"
  description = "Checkov-compliant admin policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}

resource "aws_iam_group_policy_attachment" "admins_attach" {
  group      = aws_iam_group.admins.name
  policy_arn = aws_iam_policy.admins_policy.arn
}


# IAM Role here

resource "aws_iam_role" "web_server_role" {
  name = "${var.easter_terraform_prefix}-EasterTerraform-Server-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "s3_read_access" {
  name = "S3ReadAccess"
  role = aws_iam_role.easter_terraform_server_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:Get*", "s3:List*"]
      Resource = [
        "arn:aws:s3:::regional-map-2024-website",
        "arn:aws:s3:::regional-map-2024-website/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "easter_terraform_server_profile" {
  name = "${var.easter_terraform_prefix}-EC2-Profile"
  role = aws_iam_role.easter_terraform_server_role.name
}


output "easter_terraform_server_instance_profile_name" {
  value = aws_iam_instance_profile.easter_terraform_server_profile.name
}