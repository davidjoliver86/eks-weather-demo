# Exporting the role itself in case additional specific policies need to be attached to it.

output "iam_role" {
  value = {
    id  = aws_iam_role.this.id
    arn = aws_iam_role.this.arn
  }
}
