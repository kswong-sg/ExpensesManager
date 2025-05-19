terraform {
  backend "s3" {
    bucket         = "tf-localstack-state"
    key            = "infra/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "tf-localstack-lock"
    endpoint       = "http://localhost:4566"
    access_key     = "test"
    secret_key     = "test"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    force_path_style = true
  }
}
