resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket
}