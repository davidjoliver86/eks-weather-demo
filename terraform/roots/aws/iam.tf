# AWS LB Controller

data "aws_iam_policy_document" "irsa_aws_lb_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_lb_controller" {
  name               = "aws-lb-controller"
  assume_role_policy = data.aws_iam_policy_document.irsa_aws_lb_controller.json
}

resource "aws_iam_policy" "aws_lb_controller" {
  name   = "aws-lb-controller"
  policy = file("${path.module}/policies/aws-lb-controller.json")
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
  role       = aws_iam_role.aws_lb_controller.id
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

# ExternalDNS

data "aws_iam_policy_document" "irsa_external_dns" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:default:external-dns"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResource"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = "external-dns"
  policy = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role" "external_dns" {
  name               = "external-dns"
  assume_role_policy = data.aws_iam_policy_document.irsa_external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.id
  policy_arn = aws_iam_policy.external_dns.arn
}

# EFS Driver

data "aws_iam_policy_document" "irsa_aws_efs_driver" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-efs-driver"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "aws_efs_driver" {
  name               = "aws-efs-driver"
  assume_role_policy = data.aws_iam_policy_document.irsa_aws_efs_driver.json
}

resource "aws_iam_policy" "aws_efs_driver" {
  name   = "aws-efs-driver"
  policy = file("${path.module}/policies/aws-efs-driver.json")
}

resource "aws_iam_role_policy_attachment" "aws_efs_driver" {
  role       = aws_iam_role.aws_efs_driver.id
  policy_arn = aws_iam_policy.aws_efs_driver.arn
}

# ECR Pusher from CI

data "aws_iam_policy_document" "irsa_aws_ecr_ci" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:sub"
      values   = ["system:serviceaccount:jenkins:ecr-ci"]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider.url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "aws_ecr_ci" {
  statement {
    actions   = ["eks:Describe*"]
    resources = [module.eks.cluster_arn]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:PutImage"
    ]
    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_role" "aws_ecr_ci" {
  name               = "aws-ecr-ci"
  assume_role_policy = data.aws_iam_policy_document.irsa_aws_ecr_ci.json
}

resource "aws_iam_policy" "aws_ecr_ci" {
  name   = "aws-ecr-ci"
  policy = data.aws_iam_policy_document.aws_ecr_ci.json
}

resource "aws_iam_role_policy_attachment" "aws_ecr_ci" {
  role       = aws_iam_role.aws_ecr_ci.id
  policy_arn = aws_iam_policy.aws_ecr_ci.arn
}
