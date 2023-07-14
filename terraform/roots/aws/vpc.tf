module "vpc" {
  source     = "../../modules/aws/vpc"
  cidr_block = "192.168.0.0/16"

  subnets = {
    public = {
      a = "192.168.0.0/24"
      b = "192.168.1.0/24"
    }
    private = {
      a = "192.168.100.0/24"
      b = "192.168.101.0/24"
    }
  }
}
