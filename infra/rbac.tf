# # Required to map IAM user into Kubernetes user
# resource "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapUsers = yamlencode([
#       {
#         userarn  = var.eks_admin_user_arn
#         username = var.eks_admin_username
#         groups   = []
#       }
#     ])
#   }

#   depends_on = [aws_eks_cluster.cluster]
# }

# resource "kubernetes_cluster_role_binding" "admin_binding" {
#   metadata {
#     name = "eks-admin-binding"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }

#   subject {
#     kind      = "User"
#     name      = var.eks_admin_username
#     api_group = "rbac.authorization.k8s.io"
#   }

#   depends_on = [kubernetes_config_map.aws_auth]
# }

resource "aws_eks_access_entry" "example" {
  cluster_name      = var.cluster_name
  principal_arn     = var.eks_admin_user_arn
  kubernetes_groups = ["group-1", "group-2"]
  type              = "STANDARD"

  depends_on = [aws_eks_cluster.cluster]
}
