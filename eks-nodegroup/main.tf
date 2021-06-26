locals {
  eks_nodes_tags = "${merge(var.common_tags, map(
    "Name", "${var.cluster_name}-asg"
  ))}"

  eks_asg_tags = [
    for common_tag_key in keys(local.eks_nodes_tags):
    {
      "ResourceId"          = "${aws_eks_node_group.eks_cluster_node_group.resources.0.autoscaling_groups.0.name}",
      "ResourceType"        = "auto-scaling-group",
      "Key"                 = "${common_tag_key}",
      "Value"               = "${local.eks_nodes_tags[common_tag_key]}",
      "PropagateAtLaunch"   = true
    }
  ]

  eks_asg_instances_tags = [
    for common_tag_key in keys(local.eks_nodes_tags):
    {
      "Key"                 = "${common_tag_key}",
      "Value"               = "${local.eks_nodes_tags[common_tag_key]}",
    }
  ]

  tags_rerun_trigger = "${join(", ", var.nodes_instance_types)}-${var.node_disk_size}-${join(", ", var.private_subnet_ids)}-${join(", ", var.eks_cluster_nodes_remote_access_sg_ids)}-${var.node_key_pair}"
}

resource "null_resource" "asg_tags" {
  triggers = {
    instance_tags = local.tags_rerun_trigger
  }

  provisioner "local-exec" {
    command = "aws --region ${var.region} autoscaling create-or-update-tags --tags '${jsonencode(local.eks_asg_tags)}'"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} autoscaling delete-tags --tags '${jsonencode(local.eks_asg_tags)}'"
  }
}

resource "null_resource" "asg_instances_tags" {
  triggers = {
    instance_tags = local.tags_rerun_trigger
  }

  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --tags '${jsonencode(local.eks_asg_instances_tags)}' --resources `aws --region ${var.region} autoscaling  describe-auto-scaling-groups --auto-scaling-group-names ${aws_eks_node_group.eks_cluster_node_group.resources.0.autoscaling_groups.0.name} | jq -r '[.AutoScalingGroups[].Instances[].InstanceId] | join(\" \")'`"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --tags '${jsonencode(local.eks_asg_instances_tags)}' --resources `aws --region ${var.region} autoscaling  describe-auto-scaling-groups --auto-scaling-group-names ${aws_eks_node_group.eks_cluster_node_group.resources.0.autoscaling_groups.0.name} | jq -r '[.AutoScalingGroups[].Instances[].InstanceId] | join(\" \")'`"
  }
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = "${var.cluster_name}"
  node_group_name = "${var.eks_nodegroup_name}"
  node_role_arn   = "${var.eks_cluster_nodes_role_arn}"
  subnet_ids      = "${var.private_subnet_ids}"

  scaling_config {
    desired_size = "${var.nodes_desired_count}"
    max_size     = "${var.nodes_max_count}"
    min_size     = "${var.nodes_min_count}"
  }

  remote_access {
    ec2_ssh_key = "${var.node_key_pair}"
    source_security_group_ids = "${var.eks_cluster_nodes_remote_access_sg_ids}"
  }

  disk_size = "${var.node_disk_size}"
  instance_types = "${var.nodes_instance_types}"

  tags = "${merge(var.common_tags, map(
    "Name", "${var.cluster_name}-node-group"
  ))}"

  lifecycle {
    ignore_changes = ["scaling_config[0].desired_size"]
  }
}	