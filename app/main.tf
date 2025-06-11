module "eks_cluster" {
  source = "../modules"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  node_group_name = "default"
  namespace       = "dev"
}