provider "aws" {
    region = "ap-south-1"
}

variable "ami" {
    description = "This is AMI for the instance"
}

variable "instance_type"{
    description = "This is instance type, for example: t2.micro"
}

resource "aws_instance" "example" {
    ami = var.ami
    instance_type = var.instance_type

}