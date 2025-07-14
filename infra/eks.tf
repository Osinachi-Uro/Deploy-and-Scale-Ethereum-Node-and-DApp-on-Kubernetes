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
    aws_iam_role_policy_attachment.eks_policies
  ]

  tags = {
    Environment = var.Environment
    Terraform   = "true"
    ProjectName = var.ProjectName
  }
}

resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.cluster_name.node_group
  node_role_arn   = aws_iam_role.cluster.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.eks_policies
  ]
}
