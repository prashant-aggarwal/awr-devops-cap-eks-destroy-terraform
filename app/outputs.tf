# Define outputs if needed, like EKS cluster endpoint etc.
output "eks_cluster_id" {
  description = "ID of the EKS cluster"
  value       = module.eks_cluster.eks_cluster_id
}
