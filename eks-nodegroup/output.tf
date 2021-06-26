output "eks_auto_scaling_group_name" {
  value = "${aws_eks_node_group.eks_cluster_node_group.resources.0.autoscaling_groups.0.name}"
}