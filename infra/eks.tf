# terraform {
#   #  required_version = ">= 1.3.2"

#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       #      version = "~> 5.0"
#     }
#   }

#   # backend "s3" {
#   #   bucket = "election-dapp-terraform-state-bucket"
#   #   key    = "eks/terraform.tfstate"
#   #   region = "us-east-1"
#   # }
# }

provider "aws" {
  region = "var.region"
}

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.8.5"

#   cluster_name    = "election-dapp-cluster"
#   cluster_version = "1.29"

#   cluster_endpoint_public_access           = true
#   enable_cluster_creator_admin_permissions = true



#   eks_managed_node_group_defaults = {
#     ami_type = "AL2023_x86_64_STANDARD"
#   }

#   eks_managed_node_groups = {
#     general = {
#       desired_capacity = 1
#       max_capacity     = 2
#       min_capacity     = 1
#       instance_types   = ["t2.micro"]
#       subnet_ids       = module.vpc.private_subnets
#     }
#   }

resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    # Referencing VPC outputs from the module
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.

  # Dependencies
  depends_on = [
    module.vpc,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Environment = var.Environment
    Terraform   = "true"
    ProjectName = var.ProjectName
  }
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
