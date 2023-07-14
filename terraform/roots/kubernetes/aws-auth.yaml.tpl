apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: ${node_group_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:masters
      rolearn: ${ecr_ci_role_arn}
      username: ecr-ci
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
