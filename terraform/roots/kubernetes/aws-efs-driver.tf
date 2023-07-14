data "aws_iam_role" "aws_efs_driver" {
  name = "aws-efs-driver"
}

resource "kubernetes_service_account" "aws_efs_driver" {
  metadata {
    name      = "aws-efs-driver"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" : data.aws_iam_role.aws_efs_driver.arn
    }
  }
}

resource "helm_release" "aws_efs_driver" {
  namespace  = "kube-system"
  name       = "aws-efs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  version    = "2.4.7" # Corresponds to app version 1.5.8

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-east-2.amazonaws.com/eks/aws-efs-csi-driver"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_efs_driver.metadata[0].name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  depends_on = [
    kubernetes_service_account.aws_efs_driver
  ]
}
