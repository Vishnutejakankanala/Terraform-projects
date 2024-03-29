provider "aws" {
    region = "us-east-1"
}

module "ec2-instance" {
    source = "./modules/ec2-instance"
    ami_value = "ami-053b0d53c279acc90"
    instance_type_value = "t2.micro"
}