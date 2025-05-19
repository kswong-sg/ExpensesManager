variable "region" {
  default = "ap-southeast-1"
}

variable "lambda_bucket" {
  description = "S3 bucket for Lambda code"
  type        = string
}

variable "lambda_key" {
  description = "Lambda zip key in S3"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}