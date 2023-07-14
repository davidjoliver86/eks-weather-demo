module "jenkins" {
  source = "../../modules/kubernetes/jenkins"

  file_system_name    = "jenkins"
  certificate_domain  = "*.davidjoliver86.xyz"
  host                = "jenkins.davidjoliver86.xyz"
  storage_class_name  = kubernetes_storage_class_v1.efs.metadata[0].name
  storage_provisioner = kubernetes_storage_class_v1.efs.storage_provisioner

  depends_on = [
    helm_release.aws_efs_driver,
    helm_release.aws_lb_controller,
    kubernetes_storage_class_v1.efs
  ]
}
