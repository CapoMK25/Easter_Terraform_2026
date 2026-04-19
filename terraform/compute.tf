# --- 1. SECURITY GROUP SETUP ---
# Security groups are free
resource "aws_security_group" "easter_terraform_sg" {
  name        = "EasterTerraform-Server-SG"
  description = "Allow direct HTTP access"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "EasterTerraform-Server-SG" }
}

# --- 2. EC2 ---
# Free tier: t3.micro, 750 hours/month for first 12 months
# Default 8 GB gp3 EBS volume is covered by the 30 GB free tier EBS allowance

resource "aws_instance" "easter_terraform_server" {
  ami                    = "ami-fake-local" # Placeholder AMI ID - use a real free-tier-eligible AMI in production (e.g., Amazon Linux 2023)
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.easter_terraform_server_profile.name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.easter_terraform_sg.id]

  # Install Nginx and start it on boot
  user_data = base64encode("#!/bin/bash\napt update\napt install -y nginx\nsystemctl start nginx\n")

  # Explicit root volume sizing to stay within free tier (30 GB EBS/month)
  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  depends_on = [
    aws_subnet.public,
    aws_security_group.easter_terraform_sg,
    aws_iam_instance_profile.easter_terraform_server_profile,
    aws_internet_gateway.igw,
    aws_route_table_association.public,
    aws_iam_role_policy.s3_read_access,
  ]

  tags = { Name = "EasterTerraform-Web-Server" }
}
