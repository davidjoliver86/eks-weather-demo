data "aws_efs_file_system" "jenkins" {
  tags = {
    Name = var.file_system_name
  }
}

data "aws_efs_access_points" "jenkins" {
  file_system_id = data.aws_efs_file_system.jenkins.file_system_id
}

data "aws_acm_certificate" "jenkins" {
  domain = var.certificate_domain
}

data "aws_iam_role" "aws_ecr_ci" {
  name = "aws-ecr-ci"
}
