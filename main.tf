provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "reservation-vpc" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name = "reservation-vpc"
  }
}

resource "aws_subnet" "web-subnet-01" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-subnet-01"
  }
}

resource "aws_subnet" "api-subnet-01" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "api-subnet-01"
  }
}

resource "aws_internet_gateway" "reservation-ig" {
  vpc_id = aws_vpc.reservation-vpc.id

  tags = {
    Name = "reservation-ig"
  }
}

resource "aws_route_table" "web-routetable" {
  vpc_id = aws_vpc.reservation-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.reservation-ig.id
  }

  tags = {
      Name = "web-routetable"
  }
}

resource "aws_route_table" "api-routetable" {
  vpc_id = aws_vpc.reservation-vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.reservation-ig.id
  }

  tags = {
      Name = "api-routetable"
  }
}

resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web-subnet-01.id
  route_table_id = aws_route_table.web-routetable.id
}

resource "aws_route_table_association" "api" {
  subnet_id      = aws_subnet.api-subnet-01.id
  route_table_id = aws_route_table.api-routetable.id
}

resource "aws_security_group" "web-api-sg" {
  name        = "web-api-sg"
  description = "Allow HTTP/SSH access"
  vpc_id      = aws_vpc.reservation-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
      Name = "web-api-sg"
  }
}

resource "aws_instance" "api-server-01" {
  ami           = "ami-0fb04413c9de69305"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web-api-sg.id]
  subnet_id     = aws_subnet.api-subnet-01.id
  key_name      = "tf-key"

  tags = {
      Name = "api-server-01"
  }  
}

resource "aws_instance" "web-server-01" {
  ami           = "ami-0fb04413c9de69305"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web-api-sg.id]
  subnet_id     = aws_subnet.web-subnet-01.id
  key_name      = "tf-key"

  tags = {
      Name = "web-server-01"
  }  
}