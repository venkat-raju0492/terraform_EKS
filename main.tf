resource "null_resource" "public_subnet_shared_tags" {
  count = "${length(var.public_subnet_ids)}"
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --resources ${var.public_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared Key=kubernetes.io/role/elb,Value=1"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --resources ${var.public_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared"
  }
}
resource "null_resource" "private_subnet_shared_tags" {
  count = "${length(var.private_subnet_ids)}"
  provisioner "local-exec" {
    command = "aws --region ${var.region} ec2 create-tags --resources ${var.private_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared Key=kubernetes.io/role/internal-elb,Value=1"
  }

  provisioner "local-exec" {
    when = "destroy"
    command = "aws --region ${var.region} ec2 delete-tags --resources ${var.private_subnet_ids[count.index]} --tags Key=kubernetes.io/cluster/${var.cluster_name},Value=shared"
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name            = "${var.cluster_name}"
  role_arn        = "${var.eks_cluster_role_arn}"
  enabled_cluster_log_types = "${var.enabled_cluster_log_types}"

  vpc_config {
    endpoint_private_access = "${var.endpoint_private_access}"
    endpoint_public_access  = "${var.endpoint_public_access}"
    security_group_ids = ["${var.eks_cluster_sg_id}"]
    subnet_ids         = "${var.private_subnet_ids}"
  }

  depends_on = [
    "aws_cloudwatch_log_group.eks_logging"
  ]

  tags = "${merge(var.common_tags, map(
    "Name", "${var.cluster_name}"
  ))}"
}

resource "aws_cloudwatch_log_group" "eks_logging" {
  name                      = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days         = "${var.eks_cloudwatch_log_retentions}"
}

