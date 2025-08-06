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
  }

  required_version = "~> 1.3"
}
