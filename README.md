# Overview

This module will do the following:
- Setup EKS cluster
- Setup managed nodes for EKS cluster

## Usage

```terraform
terraform {
  backend "s3" {}
}

provider "aws" {
  region = "${var.region}"
}

locals {
  cluster_name = "${var.project}-eks-${var.env}"

  # Common tags to be assigned to all resources
  common_tags = {
    Project = "${var.project}"
    Environment = "${var.env}"
    CreatedBy = "Terraform"
  }
}

module "EKS" {
  source = "git@github.levi-site.com:LSCO/terraform-EKS.git?ref=VERSION-NO."
  region = "${var.region}"
  public_subnet_ids = "${var.public_subnet_ids}"
  cluster_name = "${local.cluster_name}"
  eks_cluster_sg_id = "<<EKS CLUSTER SECURITYGROUP ID>>"
  eks_cluster_role_arn = "<<EKS CLUSTER SECURITY ROLE IAM ARN>>"
  private_subnet_ids = "${var.private_subnet_ids}"
  endpoint_private_access = "${var.endpoint_private_access}"
  endpoint_public_access = "${var.endpoint_public_access}"
  common_tags = "${local.common_tags}"
}

module "EKS-Nodegroup" {
  source = "git@github.levi-site.com:LSCO/terraform-EKS.git//eks-nodegroup?ref=VERSION-NO"
  region = "${var.region}"
  cluster_name = "${module.EKS.eks_cluster_name}"
  eks_nodegroup_name = "${var.cluster_name}-node-group"
  public_subnet_ids = "${var.public_subnet_ids}"
  private_subnet_ids = "${var.private_subnet_ids}"
  eks_cluster_nodes_role_arn = "<<EKS NODEGROUP ROLE IAM ARN>>"
  eks_cluster_nodes_remote_access_sg_ids = ["${var.bastion_host_sg_id}"]
  nodes_min_count = "${var.asg_ec2_min_count}"
  nodes_max_count = "${var.asg_ec2_max_count}"
  nodes_desired_count = "${var.asg_ec2_desired_count}"
  nodes_instance_types = "${var.asg_instance_type}"
  node_disk_size = "${var.ec2_volume_size}"
  node_key_pair = "${var.key_pair}"
  common_tags = "${local.common_tags}"
}
```
