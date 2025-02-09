variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "source_instance_id" {
  description = "ID of the EC2 instance to create the AMI from"
  type        = string
}

variable "ami_name" {
  description = "Name of the AMI to create"
  type        = string
  default     = "sprint2-ami"
}