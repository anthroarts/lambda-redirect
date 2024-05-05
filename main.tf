locals {
  domains = keys(var.domain_mapping)
  resource_suffix = var.resource_suffix != "" ? "-${var.resource_suffix}" : ""
}

data "archive_file" "redirect_lambda" {
  type = "zip"

  source {
    content = templatefile("${path.module}/src/index.py", {
      domain_mapping : var.domain_mapping,
      redirect_code : var.http_redirect_code
      }
    )
    filename = "index.py"
  }

  output_path = "${path.module}/build/lambda_redirect${local.resource_suffix}.zip"
}

resource "aws_cloudwatch_log_group" "redirect_lambda" {
  name              = "/aws/lambda/redirect_lambda${local.resource_suffix}"
  retention_in_days = 7
}

resource "aws_lambda_function" "redirect_lambda" {
  filename         = data.archive_file.redirect_lambda.output_path
  function_name    = "redirect_lambda${local.resource_suffix}"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.redirect_lambda.output_base64sha256
  runtime          = "python3.8" # hard to believe this is the latest in 2021...
  publish          = true
  memory_size      = 128
  timeout          = 3
  depends_on       = [aws_cloudwatch_log_group.redirect_lambda]
}

resource "aws_lambda_permission" "redirect" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.redirect.execution_arn}/*/*"
}

# Execution role

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    sid     = "LambdaCanAssumeThisRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "CreateLogStreamsAndWriteLogs"
    # no permissions for CreateLogGroup - only explicitly created groups
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:${aws_cloudwatch_log_group.redirect_lambda.name}:*"]
    # resources = ["arn:aws:logs:*"]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "lambda-policy${local.resource_suffix}"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "redirect-lambda-execution-role${local.resource_suffix}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# API Gateway

resource "aws_api_gateway_rest_api" "redirect" {
  name = "redirect-lambda"
}

resource "aws_api_gateway_method" "redirect_root" {
  rest_api_id   = aws_api_gateway_rest_api.redirect.id
  resource_id   = aws_api_gateway_rest_api.redirect.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "redirect_root" {
  rest_api_id = aws_api_gateway_rest_api.redirect.id
  resource_id = aws_api_gateway_method.redirect_root.resource_id
  http_method = aws_api_gateway_method.redirect_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redirect_lambda.invoke_arn
}

resource "aws_api_gateway_resource" "redirect" {
  rest_api_id = aws_api_gateway_rest_api.redirect.id
  parent_id   = aws_api_gateway_rest_api.redirect.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "redirect" {
  rest_api_id   = aws_api_gateway_rest_api.redirect.id
  resource_id   = aws_api_gateway_resource.redirect.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "redirect" {
  rest_api_id             = aws_api_gateway_rest_api.redirect.id
  resource_id             = aws_api_gateway_resource.redirect.id
  http_method             = aws_api_gateway_method.redirect.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.redirect_lambda.invoke_arn
}

# Changes to API gateway resources may require a new deployment. Try:
# terraform apply -replace aws_api_gateway_deployment.redirect
resource "aws_api_gateway_deployment" "redirect" {
  depends_on = [
    aws_api_gateway_integration.redirect,
  ]

  rest_api_id = aws_api_gateway_rest_api.redirect.id
  stage_name  = "prod"
}

resource "aws_api_gateway_domain_name" "domain" {
  for_each = toset(local.domains)

  domain_name = each.key

  certificate_arn = var.aws_acm_certificate.arn
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  for_each = aws_api_gateway_domain_name.domain

  api_id      = aws_api_gateway_rest_api.redirect.id
  stage_name  = aws_api_gateway_deployment.redirect.stage_name
  domain_name = each.value.domain_name
}
