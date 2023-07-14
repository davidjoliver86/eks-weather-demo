data "aws_iam_role" "node_group" {
  name = "weather-ng"
}

data "aws_iam_role" "ecr_ci" {
  name = "aws-ecr-ci"
}

resource "local_file" "aws_auth" {
  content = templatefile("${path.module}/aws-auth.yaml.tpl", {
    node_group_role_arn = data.aws_iam_role.node_group.arn,
    ecr_ci_role_arn     = data.aws_iam_role.ecr_ci.arn
  })
  filename        = "${path.module}/aws-auth.yaml"
  file_permission = "0644"
}
