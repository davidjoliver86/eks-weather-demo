data "aws_iam_role" "aws_lb_controller" {
  name = "aws-lb-controller"
}

resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" : data.aws_iam_role.aws_lb_controller.arn
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.5.4" # Corresponds to app version 2.5.3

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.weather.name
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.aws_lb_controller.metadata[0].name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  depends_on = [
    kubernetes_service_account.aws_lb_controller
  ]
}

# Ensure that AWS LB is the cluster's default Ingress class
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/ingress/ingress_class/#ingressclass

resource "kubernetes_ingress_class" "aws_lb_controller" {
  metadata {
    name = "aws-lb-controller"
    annotations = {
      "ingressclass.kubernetes.io/is-default-class" = true
    }
  }
  spec {
    controller = "ingress.k8s.aws/alb"
  }
}
