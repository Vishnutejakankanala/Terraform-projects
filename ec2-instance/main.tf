provider "aws" {
 region = "us-east-1" 
}

resource "aws_instance" "example" {
  ami = "ami-03a6eaae9938c858c"    #edit the ami id
  instance_type = "t2.micro"
}
