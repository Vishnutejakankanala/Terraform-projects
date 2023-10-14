provider "aws" {
  region = "us-east-1"
}

module "ec2-instance" {
  source = "./ec2-instance"
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
