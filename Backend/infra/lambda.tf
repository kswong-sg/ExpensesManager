resource "aws_lambda_function" "process" {
  function_name = "ProcessExpenseFunction"
  handler       = "handler.process"
  runtime       = "python3.12"
  timeout       = 60
  memory_size   = 256

  s3_bucket = var.lambda_bucket
  s3_key    = var.lambda_key

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      BUCKET = var.lambda_bucket
      TABLE  = var.table_name
    }
  }
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "process-api"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.http_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.process.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "process_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /process"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}