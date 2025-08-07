terraform {
  backend "s3" {
    bucket = "election-dapp-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}
