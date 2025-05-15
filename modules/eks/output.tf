output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}
output "eks_cluster_ca" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}