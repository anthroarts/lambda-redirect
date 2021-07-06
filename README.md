# lambda-redirect

Yet another serverless lambda redirect. This one accepts a list of domain names and redirects them to a URL. For example:

```hcl
module "redirect" {
  source = "../lambda-redirect"

  domain_mapping = {
    "test.example.com": "https://example.com/test",
    "mail.example.com": "https://mailprovider.com",
  }
  aws_acm_certificate = aws_acm_certificate.dev
  http_redirect_code = 302
}
```
This redirect will append the path to redirected URLs. A user visiting `test.example.com/path` will be redirected to `https://example.com/test/path`. Note that the / in the URL will be appended to the mapped URL, which works well for top level domains but may cause issues trying to redirect to a specific document.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.15 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.15 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_base_path_mapping.mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_base_path_mapping) | resource |
| [aws_api_gateway_deployment.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_domain_name.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_domain_name) | resource |
| [aws_api_gateway_integration.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.redirect_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.redirect_root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_cloudwatch_log_group.redirect_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.redirect_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.redirect](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.redirect_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_acm_certificate"></a> [aws\_acm\_certificate](#input\_aws\_acm\_certificate) | ACM certificate to use with the source domains (must be in us-east-1!) | <pre>object({<br>    arn = string<br>  })</pre> | n/a | yes |
| <a name="input_domain_mapping"></a> [domain\_mapping](#input\_domain\_mapping) | A key/value map of source domains -> target redirects. For example: domain\_mapping: {"test.example.com": "https://example.com/test"} | `map(string)` | n/a | yes |
| <a name="input_http_redirect_code"></a> [http\_redirect\_code](#input\_http\_redirect\_code) | Which HTTP redirect code to use (301 or 302) | `string` | `"301"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_redirect_cloudfront_domains"></a> [redirect\_cloudfront\_domains](#output\_redirect\_cloudfront\_domains) | n/a |
<!-- END_TF_DOCS -->