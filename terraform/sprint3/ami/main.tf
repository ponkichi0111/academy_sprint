provider "aws" {
  region = var.region
}

# AMI作成
resource "aws_ami_from_instance" "example_ami" {
  name               = var.ami_name
  source_instance_id = var.source_instance_id
  description        = "AMI created from EC2 instance managed by Terraform"

  tags = {
    Name = var.ami_name
  }
}