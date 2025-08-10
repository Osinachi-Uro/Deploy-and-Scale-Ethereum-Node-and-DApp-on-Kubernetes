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
      notifications = {
        enabled = true
        secret = {
          items = {
            "slack-token" = var.slack_webhook_url
          }
        }
        config = {
          "service.slack" = <<EOT
token: $slack-token
EOT
          "triggers"      = <<EOT
triggers:
  - name: on-sync-running
    condition: app.status.operationState.phase in ['Running']
    template: app-sync-running
  - name: on-sync-succeeded
    condition: app.status.operationState.phase in ['Succeeded']
    template: app-deployed
  - name: on-sync-failed
    condition: app.status.operationState.phase in ['Failed']
    template: app-sync-failed
  - name: on-health-degraded
    condition: app.status.health.status == 'Degraded'
    template: app-health-degraded
EOT
          "templates"     = <<EOT
templates:
  - name: app-sync-running
    slack:
      attachments:
        - title: "{{.app.metadata.name}} deployment started"
          color: "#0DADEA"
          text: "Namespace: {{.app.spec.destination.namespace}}, Initiated by: {{.app.status.operationState.operation.initiatedBy.username}}"

  - name: app-deployed
    slack:
      attachments:
        - title: "{{.app.metadata.name}} successfully deployed"
          color: "#18be52"
          text: "Namespace: {{.app.spec.destination.namespace}}, Revision: {{.app.status.sync.revision | substr 0 7}}"

  - name: app-sync-failed
    slack:
      attachments:
        - title: "{{.app.metadata.name}} sync failed"
          color: "#E96D76"
          text: "{{.app.status.operationState.message}}"

  - name: app-health-degraded
    slack:
      attachments:
        - title: "{{.app.metadata.name}} health degraded"
          color: "#f4c430"
          text: "Current health: {{.app.status.health.status}}"
EOT
          "subscriptions" = <<EOT
subscriptions:
  - recipients:
      - slack:#general
    triggers:
      - on-sync-running
      - on-sync-succeeded
      - on-sync-failed
      - on-health-degraded
EOT
        }
      }
    })
  ]

  depends_on = [aws_eks_node_group.dapp]
}
