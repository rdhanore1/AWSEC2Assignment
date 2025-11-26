variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "ami" {
  description = "Amazon Linux 2 AMI (Free Tier Eligible)"
  type        = string
  default     = "ami-0d176f79571d18a8f"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier Eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH Key Pair name"
  type        = string
}
