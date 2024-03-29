# Defined the aws provider configuration 
provider "aws" {
  region = "us-east-1"
}

variable "cidr" {
    default = "10.0.0.0/16"
}

#create key pair
resource "aws_key_pair" "example" {
  key_name = "pem"
  public_key = file("~/Downloads/pem.pem")
}

#create vpc with cidr block
resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr
}

# create a subnet
resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = "true"
}

# create internet gateway to connect vpc
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.my_vpc.id
}

#create rout table to connect internet gateway
resource "aws_route_table" "rt-1" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

# route table associated with subnet
resource "aws_route_table_association" "rta-1" {
    subnet_id = aws_subnet.subnet-1.id
    route_table_id = aws_route_table.rt-1.id
}

# create a security group
resource "aws_security_group" "sg-1" {
    name = "web"
    vpc_id = aws_vpc.my_vpc.id  

    ingress {
        description = "HTTP from vpc"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      name = "sg"
    }
}


#create instance and accociated with vpc
resource "aws_instance" "example" {
    instance_type = "t2.micro"
    ami = "ami-03a6eaae9938c858c"
    key_name = "pem"
    vpc_security_group_ids = [aws_security_group.sg-1.id]
    subnet_id = aws_subnet.subnet-1.id

    connection {
      type = "ssh"
      user = "ec2-user"
      private_key = file("~/Downloads/pem.pem")
      host = self.public_ip
    }

    # File provisioner to copy a file from local to the remote EC2 instance
    provisioner "file" {
        source = "app.py"
        destination = "/home/ec2-user/app.py"
    }

    provisioner "remote-exec" {
      inline = [ "echo 'Hello form the remote instance'",
      "sudo apt update -y", # Update package lists (for ec2-user)
      "sudo apt-get install -y", 
      "python3-pip",  # Example package installation
      "cd /home/ec2-user",
      "sudo pip3 install flask",
      "sudo python3 app.py &&",
      ]
    }
}