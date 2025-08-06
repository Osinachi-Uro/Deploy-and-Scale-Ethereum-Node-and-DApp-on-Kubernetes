
# Create service account token secret argocd to authenticate int the cluster
resource "kubernetes_secret" "argocd_sa_token" {
  metadata {
    name      = "argocd-application-controller-token"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "argocd-application-controller"
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    helm_release.argocd,
    kubernetes_cluster_role_binding.argocd_application_controller
  ]
}

## Add Cluster to ArgoCD with Service Account Authentication
# ArgoCD cluster registration
# Wait for the token to be populated

resource "time_sleep" "wait_for_token" {
  depends_on      = [kubernetes_secret.argocd_sa_token]
  create_duration = "30s"
}

# Get the service account token
data "kubernetes_secret" "argocd_sa_token" {
  metadata {
    name      = kubernetes_secret.argocd_sa_token.metadata[0].name
    namespace = kubernetes_secret.argocd_sa_token.metadata[0].namespace
  }
  depends_on = [time_sleep.wait_for_token]
}

# Create ArgoCD cluster secret with proper service account authentication
resource "kubernetes_secret" "argocd_cluster" {
  metadata {
    name      = "${aws_eks_cluster.main.name}-cluster"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  type = "Opaque"

  data = {
    name   = aws_eks_cluster.main.name
    server = aws_eks_cluster.main.endpoint
    config = base64encode(jsonencode({
      bearerToken = base64decode(data.kubernetes_secret.argocd_sa_token.data["token"])
      tlsClientConfig = {
        caData = aws_eks_cluster.main.certificate_authority[0].data
      }
    }))
  }

  depends_on = [data.kubernetes_secret.argocd_sa_token]
}
