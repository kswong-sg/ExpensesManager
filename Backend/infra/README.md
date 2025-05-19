# Infrastructure Setup on AWS

## Pre-Req
Setup Terraform state management. 
```bash
terraform init
terraform apply
```

## Local development
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

