provider "aws" {
    region = "ap-south-1"
}

variable "ami" {
    description = "value for the ami"
}

variable "instance_type" {
    description = "value for the instance type, for example: t2.micro"
    type = map(string)

    default = {
    "dev" = "t2.micro"
    "state" = "t2.micro"
    "prod" = "t2.micro"
    }
}

module "ec2-instance" {
    source = "./modules/ec2-instance"
    ami = "ami-0c42696027a8ede58"
    instance_type = "t2.micro"
}


#Terraform workspace new dev   ( new file is created - terraform.tfstate.d > dev , stage , prod )
#Terraform workspace select dev > terraform apply  