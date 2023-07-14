# Used mainly to test the AWS LB ingress controller and SSL cert usage

data "aws_acm_certificate" "wildcard" {
  domain = "*.davidjoliver86.xyz"
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    type                = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"
    port {
      port        = 80
      target_port = 80
      name        = "http"
    }
    selector = {
      app = "nginx"
    }
  }
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx"
          port {
            container_port = 80
            name           = "http"
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "nginx" {
  metadata {
    name = "nginx"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.wildcard.arn
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTP" : 80, "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"    = 443
      "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    }
  }
  spec {
    rule {
      host = "nginx.davidjoliver86.xyz"
      http {
        path {
          backend {
            service {
              name = "nginx"
              port {
                number = 80
              }
            }
          }
          path      = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}
