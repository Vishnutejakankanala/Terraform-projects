# change file name as main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
 
profile="vishnu2"
}

########### Create a VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true 
    
  tags = {
    Name = "EKYC VPC"
  }
}

# Create Web layer Public Subnet
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  
  tags = {
    Name = "SN-BASTION-EKYC-1"
  }
}

# Create Web layer Private Subnet
resource "aws_subnet" "SN-Private" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  
  tags = {
    Name = "SN-Private"
  }
}

# Create Web layer Public Subnet
resource "aws_subnet" "web-subnet-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  
  
  tags = {
    Name = "SN-BASTION-EKYC-2"
  }
}

# Create Web layer Private Subnet
resource "aws_subnet" "SN-Private-2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  
  tags = {
    Name = "SN-Private-2"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "EKYC-IGW"
  }
}

# Create Web layber route table
resource "aws_route_table" "web-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "EKYC-IGRT"
  }
}



# Create Web Subnet association with Web route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.web-subnet-1.id
  route_table_id = aws_route_table.web-rt.id
}

# Create Web Subnet association with Web route table
resource "aws_route_table_association" "c" {
  subnet_id      = aws_subnet.web-subnet-2.id
  route_table_id = aws_route_table.web-rt.id
}

resource "aws_eip" "eip-PrivateSN" {
  domain = "vpc"
}



resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.eip-PrivateSN.id
  subnet_id     = aws_subnet.web-subnet-2.id

  tags = {
    Name = "gw NAT-2"
  }
}

# Create NAT Gate Way route table
resource "aws_route_table" "nat-rt" {
  vpc_id = aws_vpc.my-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
    
  }

  tags = {
    Name = "NATRT"
  }
}

# Create App Subnet association with NAT route table
resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.SN-Private.id
  route_table_id = aws_route_table.nat-rt.id
}

resource "aws_eip" "eip-PrivateSN-2" {
  domain = "vpc"
}



resource "aws_nat_gateway" "example-2" {
  allocation_id = aws_eip.eip-PrivateSN-2.id
  subnet_id     = aws_subnet.web-subnet-2.id

  tags = {
    Name = "gw NAT-2"
  }
}

# Create NAT Gate Way route table
resource "aws_route_table" "nat-rt-2" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example-2.id

  }

  tags = {
    Name = "NATRT-2"
  }
}

# Create App Subnet association with NAT route table
resource "aws_route_table_association" "d" {
  subnet_id      = aws_subnet.SN-Private-2.id
  route_table_id = aws_route_table.nat-rt-2.id
}

# Create Web Security Group
resource "aws_security_group" "webserver-sg" {
  name        = "Web-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.my-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-SG"
  }
}

#Create EC2 Instance for BASTION
resource "aws_instance" "webserver1" {
  ami                    = "ami-05fa00d4c63e32376"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.web-subnet-1.id
  key_name               = "user1"

  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("C:/Users/Downloads/user")
      timeout     = "4m"
   }

  tags = {
    Name = "public-application"
  }
}

#Create EC2 Instance for Application
resource "aws_instance" "Application" {
  ami                    = "ami-052efd3df9dad4825"
  instance_type          = "t2.micro"
  availability_zone      = "us-east-1a"
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.SN-Private.id
  key_name               = "user1"
  
  tags = {
    Name = "private-application"
  }
}




# Give a terraform required provider, set the region and profile.
# create vpc
# create two public subnets and 2 private subnets.
# create internet gateway with given vpc
# Create rout tables attach to internet gateway and vpc 
# Both subnets accociated with rout table
# Create elastic ip's to private subnets 1&2
# create two Nat gateways with rout tables
# Associate private subnet to nat gateway
# Create security groups and attach ports 22-ssh, 80-HTTP & 300-TCP 

