terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = "us-west-1"
  profile = var.region
}

data "aws_eks_cluster_auth " "cluster_name" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster" "cluster_name" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster_name.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster_name.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster_name.token
}