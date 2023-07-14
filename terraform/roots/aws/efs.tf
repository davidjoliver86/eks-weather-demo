resource "aws_efs_file_system" "jenkins" {
  tags = {
    Name = "jenkins"
  }
}

resource "aws_efs_mount_target" "jenkins" {
  count           = length(module.vpc.subnet_ids.private)
  file_system_id  = aws_efs_file_system.jenkins.id
  subnet_id       = module.vpc.subnet_ids.private[count.index]
  security_groups = [aws_security_group.nfs_inbound.id]
}

resource "aws_efs_access_point" "jenkins" {
  file_system_id = aws_efs_file_system.jenkins.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/var/jenkins_home"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 0777
    }
  }
}
