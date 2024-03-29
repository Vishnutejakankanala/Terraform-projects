# Configure Terraform Remote Backend

terraform {
  backend "s3" {
    bucket = "mybucket-vishnu-1"          #s3 bucket name
    key    = "vishnu/terraform.tfstate"
    region = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"     #Configure the DynamoDB table name in your Terraform backend configuration
  }
}