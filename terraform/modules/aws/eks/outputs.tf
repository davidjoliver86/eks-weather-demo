output "cluster_arn" {
  value = aws_eks_cluster.this.arn
}

output "cluster_name" {
  value = var.cluster_name
}

output "oidc_provider" {
  value = aws_iam_openid_connect_provider.this
}
