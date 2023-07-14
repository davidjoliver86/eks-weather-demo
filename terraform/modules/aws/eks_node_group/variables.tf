variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "node_group_role_name_override" {
  type        = string
  description = "Override the name of the node group IAM role if desired; will otherwise default to the node group name."
  default     = ""
}

variable "ami_type" {
  type    = string
  default = "AL2_x86_64"
}

variable "subnet_ids" {
  type = list(string)
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "ec2_ssh_keypair_name" {
  type    = string
  default = ""
}

variable "source_security_group_ids" {
  type    = list(string)
  default = []
}

variable "disk_size" {
  type    = number
  default = 20 # EKS default
}

variable "instance_types" {
  type = list(string)
}
