module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = var.Environment
  }
}

# Create security group for EKS nodes
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Environment = var.Environment
  }
}

# Allow all inbound traffic from within the same security group (node-to-node)
resource "aws_vpc_security_group_ingress_rule" "node_to_node" {
  security_group_id            = aws_security_group.eks_nodes_sg.id
  description                  = "Allow node-to-node communication"
  from_port                    = 0
  to_port                      = 0
  ip_protocol                  = "-1" # all protocols
  referenced_security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow inbound from EKS control plane to worker nodes
resource "aws_vpc_security_group_ingress_rule" "eks_control_plane" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow EKS control plane to connect to nodes"
  from_port         = 1025
  to_port           = 65535
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Allow all egress traffic (needed for pulling images, updates)
resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Allow all outbound traffic to anywhere"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
