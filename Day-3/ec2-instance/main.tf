provider "aws"{
  region = "us-east-1"
}

resource "aws_instance" "example" {
  instance_type = var.instance_type_value
  ami = var.ami_value
  }
