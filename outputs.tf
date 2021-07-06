output "redirect_cloudfront_domains" {
  description = "A map of redirect domains to CloudFront DNS names. Configure these as ALIAS or CNAME records in Route53."
  value = tomap({
    for domain_name, domain in aws_api_gateway_domain_name.domain : domain_name => domain.cloudfront_domain_name
  })
}
