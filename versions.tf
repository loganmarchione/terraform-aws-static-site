terraform {
  required_version = ">= 1.0.2"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.15.0"
      configuration_aliases = [aws.us-east-1]
    }
  }
}
