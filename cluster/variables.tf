# AWS Region
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
}

# VPC CIDR Block
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet Configuration


variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.0.0/24"] # Two or any  subnets can be added in the VPC
}

variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# SSH Key
variable "ssh_key_name" {
  description = "The SSH key name for connecting to instances"
  type        = string
  default     = "Enter-you-key-name"
}

# EKS Node Group Configuration
variable "eks_instance_type" {
  description = "The EC2 instance type for the EKS node group"
  type        = string
  default     = "t2.large"
}

variable "desired_nodes" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "min_nodes" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 3
}

# Resource Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    Owner       = "MyTeam"
  }
}
