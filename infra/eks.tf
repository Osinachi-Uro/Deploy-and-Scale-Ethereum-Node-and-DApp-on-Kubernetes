resource "aws_eks_cluster" "cluster" {
  name = var.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = "1.31"

  vpc_config {
    # Referencing VPC outputs from the module
    subnet_ids = module.vpc.private_subnets
  }

  # Dependencies
  depends_on = [
    module.vpc,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy
  ]

  tags = {
    Environment = var.Environment
    Terraform   = "true"
    ProjectName = var.ProjectName
  }
}
