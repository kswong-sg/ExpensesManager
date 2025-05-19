# Infrastructure Setup on AWS

# Local development
LocalStack with Podman:

Podman CLI Command (One-liner)
You can launch LocalStack using:

```bash
podman run -d --name localstack \
  -p 4566:4566 -p 4571:4571 \
  -e SERVICES="s3,dynamodb,lambda,apigateway,iam" \
  -e DEBUG=1 \
  -v /var/run/podman/podman.sock:/var/run/docker.sock \
  -v "$(pwd)/.localstack:/tmp/localstack" \
  -v "/tmp/localstack:/var/lib/localstack" \
  localstack/localstack:latest
```
✅ Note: If Podman is rootless, replace /var/run/docker.sock with Podman's socket location (often /run/user/1000/podman/podman.sock).



Running LocalStack (localstack start)

Setting AWS credentials to dummy values (AWS_ACCESS_KEY_ID=test AWS_SECRET_ACCESS_KEY=test)

Applying Terraform:

```bash
terraform init  
terraform apply
```

Following is the docker-compose.yml to launch LocalStack and tools like awslocal.



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