data "aws_iam_role" "external_dns" {
  name = "external-dns"
}

# Resources translated from yaml manifests:
# https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#manifest-for-clusters-with-rbac-enabled

resource "kubernetes_service_account" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" : data.aws_iam_role.external_dns.arn
    }
  }
}

resource "kubernetes_cluster_role" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
  rule {
    api_groups = [""]
    resources  = ["services", "endpoints", "pods", "nodes"]
    verbs      = ["get", "watch", "list"]
  }
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_cluster_role_binding" "external_dns" {
  metadata {
    name = "external-dns-viewer"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "external-dns"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "external-dns"
    namespace = "default"
  }
}

resource "kubernetes_deployment" "external_dns" {
  metadata {
    name = "external-dns"
    labels = {
      "app.kubernetes.io/name" = "external-dns"
    }
  }
  spec {
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "external-dns"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "external-dns"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.external_dns.metadata[0].name
        container {
          name  = "external-dns"
          image = "registry.k8s.io/external-dns/external-dns:v0.13.5"
          args = [
            "--source=service",
            "--source=ingress",
            "--domain-filter=davidjoliver86.xyz",
            "--provider=aws",
            "--policy=upsert-only",
            "--aws-zone-type=public",
            "--registry=txt",
            "--txt-owner-id=external-dns"
          ]
          env {
            name  = "AWS_DEFAULT_REGION"
            value = "us-east-2"
          }
        }
      }
    }
  }
}
