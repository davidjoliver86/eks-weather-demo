variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.27"
}

variable "subnet_ids" {
  type = list(string)
}
