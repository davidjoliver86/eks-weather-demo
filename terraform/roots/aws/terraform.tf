terraform {
  backend "s3" {
    bucket  = "davidjoliver86-terraform-state"
    key     = "tfstate/eks-weather-demo.tfstate"
    region  = "us-east-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  default_tags {
    tags = {
      project = "eks-weather-demo"
    }
  }
}
