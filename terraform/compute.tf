# --- 1. SECURITY GROUP SETUP ---
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

resource "aws_instance" "easter_terraform_server" {
  ami                  = "ami-fake-local" # Placeholder AMI ID, to be changed to a valid one in the target region
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.easter_terraform_server_profile.name
  subnet_id            = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.easter_terraform_sg.id]

  # Install Nginx and start it on boot
  user_data = base64encode("#!/bin/bash\napt update\napt install -y nginx\nsystemctl start nginx\n")

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