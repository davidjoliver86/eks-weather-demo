resource "random_password" "admin" {
  length           = 24
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  override_special = "!@#$%^&*-+?"
}

resource "kubernetes_secret_v1" "admin_password" {
  metadata {
    name      = "admin-password"
    namespace = var.namespace
  }
  type = "kubernetes.io/basic-auth"
  data = {
    username = "admin"
    password = random_password.admin.result
  }
}
