variable "aws_region" {
  description = "AWS region to launch into"
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  default     = ""
}

variable "vpc_id" {
  description = "AWS VPC to use"
  default     = "vpc-7d578a1b"
}

variable "subnet_ids" {
  description = "AWS subnets to use"
  default = [
    "subnet-e85f12a1",
    "subnet-7f41d524"
  ]
}

variable "ami" {
  description = "AWS AMI to launch"
  default     = ""
}

