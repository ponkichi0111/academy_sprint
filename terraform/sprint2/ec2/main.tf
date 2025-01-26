# sprint2
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
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "web-subnet-01"
  }
}

resource "aws_subnet" "api-subnet-01" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "api-subnet-01"
  }
}

resource "aws_subnet" "db-subnet-01" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "db-subnet-01"
  }
}

resource "aws_subnet" "db-subnet-02" {
  vpc_id     = aws_vpc.reservation-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-1c"
  map_public_ip_on_launch = false
  
  tags = {
    Name = "db-subnet-02"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.db-subnet-01.id, aws_subnet.db-subnet-02.id]

  tags = {
    Name = "db_subnet_group"
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

resource "aws_security_group" "db-sg" {
  name        = "db-sg"
  description = "Allow HTTP/SSH access"
  vpc_id      = aws_vpc.reservation-vpc.id

  ingress {
    description = "RDS"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.web-api-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
      Name = "db-sg"
  }
}

resource "aws_instance" "api-server-01" {
  ami           = "ami-0fb04413c9de69305"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.web-api-sg.id]
  subnet_id     = aws_subnet.api-subnet-01.id
  key_name      = "tf-key"

  # コンソールから停止しても再構築されないようにパブリックIPを無視する
  lifecycle {
    ignore_changes = [
      associate_public_ip_address
    ]
  }

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

  # コンソールから停止しても再構築されないようにパブリックIPを無視する
  lifecycle {
    ignore_changes = [
      associate_public_ip_address
    ]
  }

  tags = {
      Name = "web-server-01"
  }  
}

resource "aws_db_instance" "rds" {
  identifier           = "reservationdb"
  db_name              = "reservationdb"
  allocated_storage    = 20
  engine               = "mysql"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "passw0rd1234"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name

  skip_final_snapshot = true
}