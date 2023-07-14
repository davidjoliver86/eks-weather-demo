resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_cluster_role_v1" "jenkins" {
  metadata {
    name = "jenkins-admin"
  }
  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_service_account_v1" "jenkins" {
  metadata {
    name      = "jenkins-admin"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
}

resource "kubernetes_service_account_v1" "ecr_ci" {
  metadata {
    name      = "ecr-ci"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" : data.aws_iam_role.aws_ecr_ci.arn
    }
  }
}

resource "kubernetes_cluster_role_binding_v1" "jenkins" {
  metadata {
    name = kubernetes_cluster_role_v1.jenkins.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.jenkins.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_cluster_role_v1.jenkins.metadata[0].name
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
}

resource "kubernetes_persistent_volume_v1" "jenkins" {
  metadata {
    name = "jenkins-pv-volume"
  }
  spec {
    storage_class_name = var.storage_class_name
    capacity = {
      storage = "10Gi"
    }
    access_modes                     = ["ReadWriteMany"]
    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      csi {
        driver        = var.storage_provisioner
        volume_handle = "${data.aws_efs_file_system.jenkins.file_system_id}::${one(data.aws_efs_access_points.jenkins.ids)}"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "jenkins" {
  metadata {
    name      = "jenkins-pv-claim"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
  spec {
    access_modes       = ["ReadWriteMany"]
    storage_class_name = var.storage_class_name
    resources {
      requests = {
        storage = "3Gi"
      }
    }
  }
}

resource "kubernetes_deployment_v1" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "jenkins"
      }
    }
    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }
      spec {
        security_context {
          fs_group    = 1000
          run_as_user = 1000
        }
        service_account_name = kubernetes_service_account_v1.jenkins.metadata[0].name
        container {
          name  = "jenkins"
          image = var.image
          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"
          }
          env {
            name  = "JENKINS_ADMIN_ID"
            value = "admin"
          }
          env {
            name  = "JENKINS_ADMIN_PASSWORD"
            value = random_password.admin.result
          }
          env {
            name  = "CASC_JENKINS_CONFIG"
            value = "/var/jenkins_home/casc.yaml"
          }
          resources {
            limits = {
              memory = "2Gi"
              cpu    = "1000m"
            }
            requests = {
              memory = "500Mi"
              cpu    = "500m"
            }
          }
          port {
            name           = "httpport"
            container_port = 8080
          }
          port {
            name           = "jnlpport"
            container_port = 50000
          }
          liveness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 90
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 5
          }
          readiness_probe {
            http_get {
              path = "/login"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }
          volume_mount {
            name       = "jenkins-data"
            mount_path = "/var/jenkins_home"
          }
        }
        volume {
          name = "jenkins-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim_v1.jenkins.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
  }
  spec {
    type                = "LoadBalancer"
    load_balancer_class = "service.k8s.aws/nlb"
    port {
      port        = 80
      target_port = 8080
      protocol    = "TCP"
    }
    selector = {
      app = "jenkins"
    }
  }
}

resource "kubernetes_service_v1" "jenkins_jnlp" {
  metadata {
    name      = "jenkins-jnlp"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 50000
      target_port = 50000
    }
    selector = {
      app = "jenkins"
    }
  }
}

resource "kubernetes_ingress_v1" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = var.namespace
    annotations = {
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.jenkins.arn
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{ "HTTP" : 80, "HTTPS" : 443 }])
      "alb.ingress.kubernetes.io/ssl-redirect"    = 443
      "alb.ingress.kubernetes.io/ssl-policy"      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
    }
  }
  spec {
    rule {
      host = var.host
      http {
        path {
          backend {
            service {
              name = "jenkins"
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
