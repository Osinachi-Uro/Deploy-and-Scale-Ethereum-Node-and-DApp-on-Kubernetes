terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
  }

  required_version = "~> 1.3"
}

provider "aws" {
  region = var.region
}
