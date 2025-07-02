# Terraform Backend Configuration for S3
# This file configures S3 as the remote backend for storing Terraform state

terraform {
  backend "s3" {
    bucket         = "terraform-state-media-streaming-app"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Note: The S3 bucket for the backend must be created manually