# Terraform Remote Backend Configuration with S3 and DynamoDB

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "example"{
  instance_type = "t2.micro"
  ami = "ami-067c21fb1979f0b27"
}

# Create an S3 Bucket for Terraform State
resource "aws_s3_bucket" "s3_bucket" {
  bucket = "mybucket-vishnu-1"
}

#Create a DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_lock" {
  name           = "terraform-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}