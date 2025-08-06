output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = aws_eks_cluster.cluster.endpoint
}

output "eks_cluster_security_group_id" {
  description = "The security group associated with the EKS cluster"
  value       = aws_eks_cluster.cluster.vpc_config[0].cluster_security_group_id
}

output "argocd_server_endpoint" {
  description = "ArgoCD server endpoint"
  value       = "Run: kubectl get svc argocd-server -n argocd"
}

output "argocd_admin_password" {
  description = "ArgoCD admin password"
  value       = "Run: kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d"
  sensitive   = true
}

# outputs.tf
data "kubernetes_service" "ganache" {
  metadata {
    name      = "ganache"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }
  depends_on = [helm_release.argocd]
}

output "ganache_rpc_url" {
  description = "Ganache RPC URL"
  value       = var.Environment == "dev" ? "http://${data.kubernetes_service.ganache.status.0.load_balancer.0.ingress.0.hostname}:8545" : "http://ganache.ganache.svc.cluster.local:8545"
}

output "ganache_network_id" {
  description = "Ganache Network ID"
  value       = var.ganache_config.network_id
}

output "ganache_accounts" {
  description = "Number of Ganache accounts"
  value       = var.ganache_config.accounts
}
