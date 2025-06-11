resource "random_string" "suffix" {
  length  = 4
  special = false
}

data "aws_vpc" "default" {
  default = true
}

# retrieves only subnet list
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# retrieves detailed information for each subnet 
data "aws_subnet" "metadata" {
  for_each = toset(data.aws_subnets.default_subnets.ids)
  id       = each.value
}


locals {
  valid_azs = ["us-east-1a", "us-east-1b"] # add "us-east-1c", "us-east-1d", "us-east-1f"
  valid_subnet_ids = [
    for subnet in data.aws_subnet.metadata : subnet.id
    if contains(local.valid_azs, subnet.availability_zone)
  ]
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}-${random_string.suffix.result}" # required
  version  = var.cluster_version
  role_arn = aws_iam_role.eks_cluster.arn # required

  vpc_config {
    subnet_ids = local.valid_subnet_ids # required
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.eks_cluster.name # required
  node_group_name = var.node_group_name              # required
  node_role_arn   = aws_iam_role.eks_node_group.arn  # required
  subnet_ids      = local.valid_subnet_ids           # required

  # required
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.default_AmazonEKSWorkerNodeMinimalPolicy,
    aws_iam_role_policy_attachment.default_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.default_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "eks_node_group" {
  name = "eks-ng-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "default_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "default_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group.name
}



