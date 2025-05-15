terraform {
  backend "s3" {
    bucket = "rnd-user-terraform-state-bucket"
    key    = "eks/eks_cluster_nginx/dev/terraform.state"
    region = "us-west-1"
  }
}
