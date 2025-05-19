resource "aws_dynamodb_table" "transactions" {
  name           = var.table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "txId"

  attribute {
    name = "txId"
    type = "S"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic" {
  name       = "lambda-basic-policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_custom_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect: "Allow",
        Action: [
          "s3:GetObject",
          "textract:AnalyzeExpense",
          "dynamodb:PutItem"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_custom" {
  name       = "lambda-custom-policy"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
