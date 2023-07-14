resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.this.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  # remote_access {
  #   ec2_ssh_key               = var.ec2_ssh_keypair_name
  #   source_security_group_ids = var.source_security_group_ids
  # }

  # remote_access {}

  disk_size      = var.disk_size
  instance_types = var.instance_types
  ami_type       = var.ami_type
}
