
resource "kubernetes_manifest" "ganache_application" {
  provider = kubernetes.eks
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "ganache"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/Osinachi-Uro/Deploying-an-Ethereum-Node-and-DApp-on-Kubernetes"
        targetRevision = "HEAD"
        path           = "ganache/"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace.argocd.metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=false"
        ]
      }
    }
  }

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_cluster
  ]
}
