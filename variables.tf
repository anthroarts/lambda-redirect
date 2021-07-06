variable "domain_mapping" {
  description = "A key/value map of source domains -> target redirects. For example: domain_mapping: {\"test.example.com\": \"https://example.com/test\"}"
  type        = map(string)
}

variable "aws_acm_certificate" {
  description = "ACM certificate to use with the source domains (must be in us-east-1!)"
  type = object({
    arn = string
  })
}

variable "http_redirect_code" {
  type        = string
  description = "Which HTTP redirect code to use (301 or 302)"
  default     = "301"
}