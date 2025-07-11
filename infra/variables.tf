variable "region" {
  default     = "us-east-1"
  description = "aws region"
  type        = string
}

variable "cluster_name" {
  description = "name of the kubernetes cluster"
  default     = "election-dapp-cluster"
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
