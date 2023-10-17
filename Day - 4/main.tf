# Terraform remote backend configuration with S3 and DynamoDB

provider "aws" {
    region = "us-east-1" 
}

resource "aws_instance" "example" {
    ami = "ami-067c21fb1979f0b27"
    instance_type = "t2.micro"
}

#create S3 bucket for terraform state file
resource "aws_s3_bucket" "s3_bucket" {
    bucket = "mybucket-vishnu-0" 
}

#create DynamoDB table for state locking 
resource "aws_dynamodb_table" "terraform_lock" {
    name = "terraform-lock"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "S"
    }
}
