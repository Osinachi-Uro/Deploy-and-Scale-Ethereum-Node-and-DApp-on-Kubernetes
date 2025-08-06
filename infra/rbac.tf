## Configure Role-based access control (RBAC) fr ArgoCD

# Create ClusterRole for ArgoCD
resource "kubernetes_cluster_role" "argocd_application_controller" {
  metadata {
    name = "argocd-application-controller"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  depends_on = [helm_release.argocd]
}

# Create ClusterRoleBinding
resource "kubernetes_cluster_role_binding" "argocd_application_controller" {
  metadata {
    name = "argocd-application-controller"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argocd_application_controller.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "argocd-application-controller"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  depends_on = [helm_release.argocd]
}
