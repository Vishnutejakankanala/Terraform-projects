provider "aws" {
 region = "us-east-1"  # Set your desired AWS region
}

resource "aws_instance" "example" {
 ami           = "ami-03a6eaae9938c858c"  # Specify an appropriate AMI ID
    instance_type = "t2.micro"
    key_name = "pem"

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("C:/Users/Downloads/pem")
      timeout     = "4m"
    }
    tags = {
        name = "public-application"
    }
}
