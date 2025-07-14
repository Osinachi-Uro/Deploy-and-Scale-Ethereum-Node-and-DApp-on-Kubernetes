variable "region" {
  description = "aws region"
  type        = string
}

variable "cluster_name" {
  description = "name of the kubernetes cluster"
  sensitive   = true
  type        = string
}

variable "ProjectName" {
  description = "value for the project name required for proper resource tagging"
  default     = "Deploy election-dapp"
  type        = string
}

variable "Environment" {
  description = "value for the project environment - dev, staging or prod. This is a good tagging practice"
  default     = "dev"
  type        = string
}

variable "vpc_cidr" {
  description = "value"
  default     = "10.0.0.0/16"
  type        = string
}

variable "eks_admin_user_arn" {
  description = "IAM ARN of the EKS admin user"
  sensitive   = true
  type        = string
}

variable "eks_admin_username" {
  description = "Username to map in aws-auth config"
  sensitive   = true
  type        = string
}
