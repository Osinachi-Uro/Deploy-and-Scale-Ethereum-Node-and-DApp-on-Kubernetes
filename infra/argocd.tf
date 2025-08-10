data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {

}

# Install ArgoCD with Helm

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
      },
      controller = {
        clusterRole = {
          create = true
          name   = "cluster-admin"
        }
      }
      notifications = {
        enabled = true
        secret = {
          items = {
            "slack-token" = var.slack_webhook_url
          }
        }
        notifiers = {
          slack = {
            token = "$slack-token"
          }
        }
        triggers = {
          on-sync-succeeded = [
            {
              when = "app.status.operationState.phase in ['Succeeded']"
              send = ["slack"]
            }
          ]
          on-sync-failed = [
            {
              when = "app.status.operationState.phase in ['Failed']"
              send = ["slack"]
            }
          ]
          on-health-degraded = [
            {
              when = "app.status.health.status == 'Degraded'"
              send = ["slack"]
            }
          ]
        }
        subscriptions = [
          {
            recipients = ["slack:#general"]
            triggers   = ["on-sync-succeeded", "on-sync-failed", "on-health-degraded"]
          }
        ]
      }
    })
  ]

  depends_on = [aws_eks_node_group.dapp]
}

# # Give ArgoCD proper permissions
# resource "kubernetes_cluster_role_binding" "argocd_admin" {
#   metadata {
#     name = "argocd-application-controller"
#   }

#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "ClusterRole"
#     name      = "cluster-admin"
#   }

#   subject {
#     kind      = "ServiceAccount"
#     name      = "argocd-application-controller"
#     namespace = "argocd"
#   }

#   depends_on = [helm_release.argocd]
# }
