# Web3 on Kubernetes Demo (Single Monorepo)

This repo shows how to deploy an Ethereum smart contract to a Ganache node on EKS using:

- Terraform (EKS provisioning)
- Helm (Ganache deployment)
- Truffle (Smart contract deployment)
- ArgoCD (GitOps)
- GitHub Actions (CI/CD)

## Execution Steps

1. Clone repo & `cd web3-k8s-demo/infra`
2. `terraform init && terraform apply`
3. Install ArgoCD on EKS cluster
4. Fork this repo & push
5. ArgoCD auto-syncs Ganache chart
6. GitHub Action deploys smart contract via Truffle
