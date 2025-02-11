# main.tf
# VPC
resource "aws_vpc" "monitor_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "monitor"
  }
}
# Geteway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.monitor_vpc.id

  tags = {
    Name = "monitor-igw"
  }
}
# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.monitor_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "monitor-public-subnet"
  }
}
# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.monitor_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "monitor-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow_all" {
  name        = "monitor-allow_all"
  description = "monitor-Allow all IPv4 traffic"
  vpc_id      = aws_vpc.monitor_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "monitor-allow_all"
  }
}
# Ec2 1
resource "aws_instance" "control-1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "control"
  }
}
# Ec2 2
resource "aws_instance" "target-1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  key_name               = var.ssh_key_name

  tags = {
    Name = "target"
  }
}