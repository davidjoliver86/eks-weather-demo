variable "namespace" {
  type    = string
  default = "jenkins"
}

variable "image" {
  type    = string
  default = "jenkins/jenkins:lts"
}

variable "file_system_name" {
  type = string
}

variable "certificate_domain" {
  type = string
}

variable "host" {
  type = string
}

variable "storage_class_name" {
  type = string
}

variable "storage_provisioner" {
  type = string
}
