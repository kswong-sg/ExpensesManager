output "lambda_function_name" {
  value = aws_lambda_function.process.function_name
}

output "api_url" {
  value = aws_apigatewayv2_api.http_api.api_endpoint
}

output "dynamodb_table" {
  value = aws_dynamodb_table.transactions.name
}