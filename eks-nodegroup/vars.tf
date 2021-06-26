variable "region" {
  description = "AWS region"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = "map"
}

variable "cluster_name" {
  description = "EKS Cluster name"
}

variable "eks_nodegroup_name" {
  description = "eks node group name"
}

variable "public_subnet_ids" {
  type = "list"
  description = "Subnet Ids to use for EKS cluster"
}

variable "private_subnet_ids" {
  type = "list"
  description = "Subnet Ids to use for EKS cluster nodes"
}


variable "nodes_desired_count" {
  description = "Autoscaling Group desired count"
  default     = "2"
}

variable "nodes_max_count" {
  description = "Autoscaling max count"
  default     = "10"
}

variable "nodes_min_count" {
  description = "Autoscaling service min count"
  default     = "1"
}

variable "nodes_instance_types" {
  type = "list"
  description = "AWS instance types to use"
  default = ["t3.medium"]
}

variable "node_disk_size" {
  description = "EC2 Volume size"
  default = 20
}

variable "node_key_pair" {
  description = "key pair"
}

variable "eks_cluster_nodes_remote_access_sg_ids" {
  type = "list"
  description = "secuirty groups ids to allow remote access from"
}

variable "eks_cluster_nodes_role_arn" {
  description = "EKS cluster nodes role ARN"
}