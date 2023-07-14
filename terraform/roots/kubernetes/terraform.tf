terraform {
  backend "s3" {
    bucket  = "davidjoliver86-terraform-state"
    key     = "tfstate/eks-weather-demo-k8s.tfstate"
    region  = "us-east-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.7.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.21.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.10.1"
    }
  }
}

data "aws_eks_cluster" "weather" {
  name = "weather"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.weather.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.weather.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.weather.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.weather.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.weather.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.weather.name]
      command     = "aws"
    }
  }
}
