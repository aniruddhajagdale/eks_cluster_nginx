terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}_cluster_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow"
        Principal : {
          Service : "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-cluster-role"
    Environment = var.env
  }
}

# Attach AWS managed EKS Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_service_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

#EKS CLuster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.cluster_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.k8_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  tags = {
    Name        = "${var.cluster_name}-cluster"
    Environment = var.env
  }

  depends_on = [
    aws_iam_role.eks_cluster_role
  ]
}


#EKS Node Role
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}_node_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17"
    Statement : [
      {
        Action : "sts:AssumeRole"
        Effect : "Allow"
        Principal : {
          Service : "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-node-role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

#EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  ami_type        = "AL2_x86_64"
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  depends_on = [
    aws_iam_role.eks_node_role,
    aws_eks_cluster.eks_cluster
  ]

  tags = {
    Name        = "${var.cluster_name}-node-group"
    Environment = var.env
  }
}
