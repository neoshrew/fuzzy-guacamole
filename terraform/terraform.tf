provider "aws" {
  region  = "us-east-1"
  profile = "personal"
}

# Leaving this as a placeholder
# terraform {
#   backend "s3" {
#     bucket         = "xxx"
#     key            = "xxx"
#     region         = "xxx"
#     dynamodb_table = "xxx"
#   }
# }
