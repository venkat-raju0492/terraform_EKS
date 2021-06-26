output "endpoint" {
  value = "${aws_eks_cluster.eks_cluster.endpoint}"
}

output "kubeconfig_certificate_authority_data" {
  value = "${aws_eks_cluster.eks_cluster.certificate_authority.0.data}"
}

output "eks_cluster_name" {
  value = "${aws_eks_cluster.eks_cluster.name}"
}

output "eks_cluster_sg_id" {
  value = aws_eks_cluster.eks_cluster.vpc_config.0.cluster_security_group_id
}

