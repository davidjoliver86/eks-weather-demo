variable "cidr_block" {
  type = string
}

variable "subnets" {
  type        = map(map(string))
  description = "Subnet CIDR blocks - define both a 'public' and 'private' object - inside, each key is the AZ and value is the CIDR block."
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "enable_dns_support" {
  type    = bool
  default = true
}
