# Change main.tf file name
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}


# Configure the AWS Provider
provider "aws" {
    region = "us-east-1"

profile="vishnu2"
}


### Create a VPC
resource "aws_vpc" "my-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

tags = {
    Name = "aws-vpc"
  }
}


# Create Internet Gateway attached to vpc
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "aws-IGW"
  }
}


# Create Web layer Public Subnet
resource "aws_subnet" "web-subnet-1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "aws-Public-SN"
  }
}

# Create Web layer Private Subnet
resource "aws_subnet" "SN-Private" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  #map_public_ip_on_launch = true
  
  tags = {
    Name = "aws-Private-SN"
  }
}


# Create Web layber route table and attach to Internet Gateway
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
