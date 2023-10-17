# configur terraform remote backend

terraform {
  backend "s3" {
    bucket = "mybucket-vishnu-0"
    key = "backend/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "terraform-lock" ##Configure the DynamoDB table name in your Terraform backend configuration
  }
}
