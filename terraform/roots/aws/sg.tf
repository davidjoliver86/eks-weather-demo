resource "aws_security_group" "nfs_inbound" {
  name   = "nfs-inbound"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "Allow inbound NFS traffic"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}
