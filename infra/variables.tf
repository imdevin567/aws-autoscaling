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
  default     = "vpc-0087b57a"
}

variable "subnet_ids" {
  description = "AWS subnets to use"
  default = [
    "subnet-28c37265",
    "subnet-38806267"
  ]
}

variable "ami" {
  description = "AWS AMI to launch"
  default     = ""
}

