output "cluster_id" {
  description = "The ID of the created EKS cluster"
  value       = aws_eks_cluster.my_cluster.id
}

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = aws_eks_node_group.my_node_group.id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  description = "The IDs of the subnets created in the VPC"
  value       = aws_subnet.my_subnet[*].id
}
