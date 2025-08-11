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
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
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
      },
      configs = {
        notifications = {
          enabled = true
          secret = {
            items = {
              "slack-token" = var.slack_webhook_url
            }
          }
          notifiers = {
            "service.slack" = {
              token = "$slack-token"
            }
          }
          templates = {
            app-sync-succeeded = {
              message = "✅ Application {{.app.metadata.name}} synced successfully."
            }
            app-sync-failed = {
              message = "❌ Application {{.app.metadata.name}} failed to sync."
            }
            app-health-degraded = {
              message = "⚠️ Application {{.app.metadata.name}} has degraded health."
            }
            app-sync-running = {
              message = "🚀 Sync in progress for {{.app.metadata.name}}..."
            }
          }
          triggers = {
            on-sync-succeeded = {
              when = "app.status.operationState.phase in ['Succeeded']"
              send = ["app-sync-succeeded"]
            }
            on-sync-failed = {
              when = "app.status.operationState.phase in ['Failed']"
              send = ["app-sync-failed"]
            }
            on-health-degraded = {
              when = "app.status.health.status == 'Degraded'"
              send = ["app-health-degraded"]
            }
            on-sync-running = {
              when = "app.status.operationState.phase in ['Running']"
              send = ["app-sync-running"]
            }
          }
          subscriptions = [
            {
              recipients = ["slack:#general"]
              triggers = [
                "on-sync-succeeded",
                "on-sync-failed",
                "on-health-degraded",
                "on-sync-running"
              ]
            }
          ]
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.dapp]
}
