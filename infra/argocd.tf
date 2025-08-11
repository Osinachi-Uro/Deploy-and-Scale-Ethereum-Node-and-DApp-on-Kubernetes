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

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
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
      }
      controller = {
        clusterRole = {
          create = true
          name   = "cluster-admin"
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.dapp]
}

resource "kubectl_manifest" "notifications_cm" {
  yaml_body  = file("${path.module}/manifests/argocd-notifications-cm.yaml")
  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "notifications_secret" {
  yaml_body  = file("${path.module}/manifests/argocd-notifications-secret.yaml")
  depends_on = [helm_release.argocd]
}



# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   create_namespace = true

#   values = [
#     yamlencode({
#       server = {
#         service = {
#           type = "LoadBalancer"
#         }
#       },
#       controller = {
#         clusterRole = {
#           create = true
#           name   = "cluster-admin"
#         }
#       },
#       notifications = {
#         enabled = true
#       },
#       extraObjects = [
#         {
#           apiVersion = "v1"
#           kind       = "ConfigMap"
#           metadata = {
#             name      = "argocd-notifications-cm"
#             namespace = "argocd"
#           }
#           data = {
#             context = yamlencode({
#               argocdUrl = "https://argocd.example.com"
#             })
#             triggers = yamlencode({
#               on-sync-succeeded = {
#                 when = "app.status.operationState.phase in ['Succeeded']"
#                 send = ["slack"]
#               }
#               on-sync-failed = {
#                 when = "app.status.operationState.phase in ['Failed']"
#                 send = ["slack"]
#               }
#               on-health-degraded = {
#                 when = "app.status.health.status == 'Degraded'"
#                 send = ["slack"]
#               }
#               on-deployment-in-progress = {
#                 when = "app.status.operationState.phase in ['Running']"
#                 send = ["slack"]
#               }
#             })
#             templates = yamlencode({
#               slack = {
#                 message = "{{.app.metadata.name}} - {{.app.status.operationState.phase}}"
#               }
#             })
#             subscriptions = yamlencode([
#               {
#                 recipients = ["slack:#general"]
#                 triggers   = ["on-sync-succeeded", "on-sync-failed", "on-health-degraded", "on-deployment-in-progress"]
#               }
#             ])
#             notifiers = yamlencode({
#               "service.slack" = {
#                 token = "$slack-token"
#               }
#             })
#           }
#         }
#       ]
#     })
#   ]

#   depends_on = [aws_eks_node_group.dapp]
# }
