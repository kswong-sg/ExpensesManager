provider "aws" {
  region                      = var.region
  access_key                  = "test"
  secret_key                  = "test"
  s3_force_path_style         = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3             = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    apigateway     = "http://localhost:4566"
    iam            = "http://localhost:4566"
  }
}

module "s3_state" {
  source      = "./modules/s3_state"
  bucket_name = "tf-localstack-state"
}

module "dynamodb_lock" {
  source     = "./modules/dynamodb_lock"
  table_name = "tf-localstack-lock"
}
