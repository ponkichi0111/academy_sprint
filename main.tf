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

  tags = {
    Name = "web-subnet-01"
  }
}

resource "aws_subnet" "api-subnet-01" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.1.0/24"
  
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