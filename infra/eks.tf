terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.68.0"
    }
  }

  backend "s3" {
    bucket = "election-dapp-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "var.region"
}



module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = "election-dapp-cluster"
  cluster_version = ">=2.7.1"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    instance_types = ["t2.micro"]
  }

  eks_managed_node_groups = {
    general = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_types = ["t2.micro"]
      ami_type       = "AL2023_x86_64_STANDARD"
      subnet_ids     = module.vpc.private_subnets
    }
  }
  # cluster_compute_config = {
  #   enabled    = true
  #   node_pools = ["general-purpose"]

  # }

  # Referencing VPC outputs from the module
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  depends_on = [module.vpc]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
