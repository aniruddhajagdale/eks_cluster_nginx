
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

module "vpc" {
  source               = "../../modules/vpc"
  env                  = var.env
  cidr_block           = var.cidr_block
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

module "eks" {
  source             = "../../modules/eks"
  env                = var.env
  cluster_name       = var.cluster_name
  k8_version         = var.cluster_version
  private_subnet_ids = module.vpc.private_subnet_ids
  desired_size       = var.desired_size
  max_nodes          = var.max_size
  min_nodes          = var.min_size
  instance_types     = var.instance_types

  providers = {
    kubernetes = kubernetes
  }
}