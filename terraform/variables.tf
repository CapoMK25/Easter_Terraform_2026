variable "easter_terraform_prefix" {
  description = "The prefix used for naming all resources"
  type        = string
  default     = "EasterTerraform"
}

variable "region" {
  description = "The AWS region for the deployment (Stockholm)"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "availability_zones" {
  type    = list(string)
  default = ["eu-north-1a", "eu-north-1b"]
}

# Free tier: t3.micro is eligible (750 hours/month for first 12 months)
# t3.nano is NOT free tier eligible
variable "instance_type" {
  description = "The size of the EC2 instance (free tier: t3.micro)"
  type        = string
  default     = "t3.micro"
}
