provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "web3-demo-cluster"
  cluster_version = "1.27"
  subnets         = ["subnet-xxxxxx", "subnet-yyyyyy"]
  vpc_id          = "vpc-xxxxxx"

  manage_aws_auth = true
}
