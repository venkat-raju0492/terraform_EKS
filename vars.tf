variable "cluster_name" {
  description = "EKS Cluster name"
}

variable "region" {
  description = "AWS region"
}

variable "public_subnet_ids" {
  description = "public subnet ids"
  type = "list"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = "map"
}

variable "enabled_cluster_log_types" {
  type = "list"
  description = "Log types to enable"
  default = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "eks_cluster_sg_id" {
  description = "EKS cluster SG ID"
}

variable "eks_cluster_role_arn" {
  description = "EKS cluster role ARN"
}

variable "eks_cloudwatch_log_retentions" {
  description = "EKS cloudwatch log retentions in days"
  default = 7
}

variable "private_subnet_ids" {
  type = "list"
  description = "Subnet Ids to use for EKS cluster and nodes"
}

variable "endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default = false
}

variable "endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default = true
}