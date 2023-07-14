# Sample deployment of a test app using EFS-backed persistent volumes

# resource "kubernetes_persistent_volume_v1" "test" {
#   metadata {
#     name = "efs-pv"
#   }
#   spec {
#     capacity = {
#       storage = "5Gi"
#     }
#     volume_mode                      = "Filesystem"
#     access_modes                     = ["ReadWriteMany"]
#     persistent_volume_reclaim_policy = "Retain"
#     storage_class_name               = kubernetes_storage_class_v1.efs.metadata[0].name
#     persistent_volume_source {
#       csi {
#         driver        = kubernetes_storage_class_v1.efs.storage_provisioner
#         volume_handle = data.aws_efs_file_system.jenkins.file_system_id
#       }
#     }
#   }
# }

# resource "kubernetes_persistent_volume_claim_v1" "test" {
#   metadata {
#     name = "efs-claim"
#   }
#   spec {
#     access_modes       = ["ReadWriteMany"]
#     storage_class_name = kubernetes_storage_class_v1.efs.metadata[0].name
#     resources {
#       requests = {
#         storage = "5Gi"
#       }
#     }
#   }
# }

# resource "kubernetes_pod_v1" "test" {
#   for_each = toset(["app1", "app2"])
#   metadata {
#     name = each.key
#   }
#   spec {
#     container {
#       name    = each.key
#       image   = "busybox"
#       command = ["/bin/sh"]
#       args    = ["-c", "while true; do echo $(date -u) >> /var/jenkins_derp/out1.txt; sleep 5; done"]
#       volume_mount {
#         name       = "persistent-storage"
#         mount_path = "/var/jenkins_derp"
#       }
#     }
#     volume {
#       name = "persistent-storage"
#       persistent_volume_claim {
#         claim_name = kubernetes_persistent_volume_claim_v1.test.metadata[0].name
#       }
#     }
#   }
# }
