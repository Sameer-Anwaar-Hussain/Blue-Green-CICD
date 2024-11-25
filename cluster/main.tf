provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = merge(var.tags, {
    Name = "my-vpc"
  })
}

# Subnets
resource "aws_subnet" "my_subnet" {
  count = length(var.subnet_cidrs)

  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "my-subnet-${count.index}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(var.tags, {
    Name = "my-igw"
  })
}

# Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = merge(var.tags, {
    Name = "my-route-table"
  })
}

# Route Table Association
resource "aws_route_table_association" "my_route_table_assoc" {
  count          = length(var.subnet_cidrs)
  subnet_id      = aws_subnet.my_subnet[count.index].id
  route_table_id = aws_route_table.my_route_table.id
}

# Security Group for Cluster
resource "aws_security_group" "my_cluster_sg" {
  vpc_id = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "my-cluster-sg"
  })
}

# Security Group for Node Group
resource "aws_security_group" "my_node_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "my-node-sg"
  })
}

# EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.my_cluster_role.arn

  vpc_config {
    subnet_ids         = aws_subnet.my_subnet[*].id
    security_group_ids = [aws_security_group.my_cluster_sg.id]
  }
}

# EKS Node Group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.my_node_group_role.arn
  subnet_ids      = aws_subnet.my_subnet[*].id

  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  instance_types = [var.eks_instance_type]

  remote_access {
    ec2_ssh_key               = var.ssh_key_name
    source_security_group_ids = [aws_security_group.my_node_sg.id]
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "my_cluster_role" {
  name = "my-cluster-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Role Policy Attachment for EKS Cluster
resource "aws_iam_role_policy_attachment" "my_cluster_policy_attachment" {
  role       = aws_iam_role.my_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for Node Group
resource "aws_iam_role" "my_node_group_role" {
  name = "my-node-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Role Policy Attachment for Node Group
resource "aws_iam_role_policy_attachment" "my_node_group_policy_attachment" {
  role       = aws_iam_role.my_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# IAM Role Policy Attachment for CNI Policy
resource "aws_iam_role_policy_attachment" "my_node_group_cni_policy" {
  role       = aws_iam_role.my_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM Role Policy Attachment for ECR Read-Only
resource "aws_iam_role_policy_attachment" "my_node_group_registry_policy" {
  role       = aws_iam_role.my_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
