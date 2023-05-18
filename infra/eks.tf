resource "aws_eks_cluster" "wiz-tech-task-eks-cluster" {
  name     = "wiz-tech-task-eks-cluster"
  role_arn = aws_iam_role.wiz-tech-task-eks-iam-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.wiz-tech-task-subnet-1.id, aws_subnet.wiz-tech-task-subnet-2-private.id, aws_subnet.wiz-tech-task-subnet-3-private.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.wiz-tech-task-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.wiz-tech-task-AmazonEKSVPCResourceController,
  ]
}

output "configure-kubectl" {
  value = "aws eks update-kubeconfig --region ap-southeast-1 --name ${aws_eks_cluster.wiz-tech-task-eks-cluster.name}"
}

# output "endpoint" {
#   value = aws_eks_cluster.wiz-tech-task-eks-cluster.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.wiz-tech-task-eks-cluster.certificate_authority[0].data
# }

data "aws_iam_policy_document" "wiz-tech-task-eks-assume-role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "wiz-tech-task-eks-iam-role" {
  name               = "wiz-tech-task-eks-iam-role"
  assume_role_policy = data.aws_iam_policy_document.wiz-tech-task-eks-assume-role.json
}

resource "aws_iam_role_policy_attachment" "wiz-tech-task-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.wiz-tech-task-eks-iam-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "wiz-tech-task-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.wiz-tech-task-eks-iam-role.name
}

resource "aws_eks_node_group" "wiz-tech-task-eks-node-group" {
  cluster_name    = aws_eks_cluster.wiz-tech-task-eks-cluster.name
  node_group_name = "wiz-tech-task-eks-node-group"
  node_role_arn   = aws_iam_role.wiz-tech-task-eks-iam-role.arn
  subnet_ids      = [aws_subnet.wiz-tech-task-subnet-2-private.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.wiz-tech-task-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.wiz-tech-task-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.wiz-tech-task-AmazonEC2ContainerRegistryReadOnly,
    aws_eks_cluster.wiz-tech-task-eks-cluster
  ]
}
resource "aws_iam_role_policy_attachment" "wiz-tech-task-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.wiz-tech-task-eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "wiz-tech-task-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.wiz-tech-task-eks-iam-role.name
}
resource "aws_iam_role_policy_attachment" "wiz-tech-task-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.wiz-tech-task-eks-iam-role.name
}