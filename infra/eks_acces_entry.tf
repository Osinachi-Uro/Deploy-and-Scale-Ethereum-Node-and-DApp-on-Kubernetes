resource "aws_eks_access_entry" "user" {
  cluster_name      = var.cluster_name
  principal_arn     = var.eks_admin_user_arn
  kubernetes_groups = ["group-1", "group-2"]
  type              = "STANDARD"

  depends_on = [aws_eks_cluster.cluster]
}
