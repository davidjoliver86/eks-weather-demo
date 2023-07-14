resource "aws_acm_certificate" "wildcard" {
  domain_name       = "*.davidjoliver86.xyz"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "wildcard" {
  certificate_arn         = aws_acm_certificate.wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.wildcard_validation : record.fqdn]
}
