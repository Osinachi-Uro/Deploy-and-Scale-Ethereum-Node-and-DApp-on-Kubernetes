# Create ArgoCD namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "dapp"
  }
  depends_on = [aws_eks_node_group.dapp]
}

# Install ArgoCD with Helm
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Ensure service account is created
  values = [
    yamlencode({
      controller = {
        serviceAccount = {
          create = true
          name   = "argocd-application-controller"
        }
      }
      server = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}
