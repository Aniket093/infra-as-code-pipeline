# Capstone Infrastructure — AWS ECS Fargate on Terraform

## Architecture

```
Internet
   │
   ▼
[ALB] ── (HTTP:80) ──► [ECS Fargate Service]
   │                          │
[Public Subnets]       [Private Subnets]
                              │
                         [ECR Image]
                         [CloudWatch Logs]

VPC (per env)
 ├── Public Subnets  (ALB, NAT Gateway)
 ├── Private Subnets (ECS Tasks)
 ├── Security Groups (ALB → ECS only)
 └── IAM Role        (ECS Task Execution)
```

## Pipeline Flow

```
push to main
     │
     ▼
  [lint]  terraform fmt + validate (staging env)
     │
     ▼
  [test]  application tests
     │
     ▼
  [build] docker build → push to ECR
     │
     ▼
  [deploy-staging]
     ├── register new task definition
     ├── update ECS service
     └── health check (5 min)
           ├── PASS → continue
           └── FAIL → rollback to previous task def + exit 1
     │
     ▼
  [deploy-prod]  ← requires manual approval (GitHub environment protection)
     ├── register new task definition (same image)
     └── update ECS service
```

## Environments

| Environment | Directory                    | CIDR          | State Key                  |
|-------------|------------------------------|---------------|----------------------------|
| dev         | enviornments/dev/            | 10.0.0.0/16   | dev/terraform.tfstate      |
| staging     | enviornments/staging/        | 10.1.0.0/16   | staging/terraform.tfstate  |
| production  | enviornments/prod/           | 10.2.0.0/16   | prod/terraform.tfstate     |

Each environment has its own `backend.tf` pointing to an isolated S3 state key and DynamoDB lock.

## Usage

```bash
cd infra/enviornments/<env>
terraform init
terraform plan
terraform apply
```

## Required GitHub Secrets

| Secret                  | Description                        |
|-------------------------|------------------------------------|
| AWS_REGION              | e.g. us-east-1                     |
| AWS_ACCESS_KEY_ID       | IAM user access key                |
| AWS_SECRET_ACCESS_KEY   | IAM user secret key                |
| ECR_REPO                | Full ECR repo URI                  |
| ECS_CLUSTER_STAGING     | Staging ECS cluster name           |
| ECS_SERVICE_STAGING     | Staging ECS service name           |
| ECS_CLUSTER_PROD        | Production ECS cluster name        |
| ECS_SERVICE_PROD        | Production ECS service name        |

Set `production` environment in GitHub → Settings → Environments with a required reviewer for manual approval gate.

## Runbook — Common Failure Scenarios

### Pipeline fails at lint/validate
- Check `terraform fmt -check` output — run `terraform fmt -recursive` locally to auto-fix
- Ensure `infra/enviornments/staging/` has valid `.tf` files

### ECS deployment stuck / health check fails
- Check CloudWatch logs: `/ecs/<env>` log group
- Check ALB target group health in AWS Console → EC2 → Target Groups
- The pipeline auto-rolls back to the previous task definition on failure
- To manually rollback: `aws ecs update-service --cluster <cluster> --service <service> --task-definition <previous-arn>`

### ECR push fails
- Verify `ECR_REPO` secret matches the full URI: `<account>.dkr.ecr.<region>.amazonaws.com/<repo>`
- Ensure the IAM user has `ecr:GetAuthorizationToken` and `ecr:BatchCheckLayerAvailability` permissions

### Terraform state lock error
- Check DynamoDB table `tf-state-lock` for a stuck lock item
- Delete the lock item manually: `aws dynamodb delete-item --table-name tf-state-lock --key '{"LockID":{"S":"<key>"}}'`

### ECS tasks failing to start
- Check task stopped reason in ECS Console → Clusters → Tasks → Stopped
- Common causes: wrong ECR image URI, missing IAM permissions, misconfigured security groups

## Estimated Monthly AWS Costs (us-east-1)

| Service              | Config                        | Est. Cost/month |
|----------------------|-------------------------------|-----------------|
| ECS Fargate          | 2 tasks × 0.25 vCPU / 0.5 GB | ~$15            |
| ALB                  | 1 ALB, low traffic            | ~$18            |
| ECR                  | ~1 GB storage                 | ~$0.10          |
| NAT Gateway          | 1 per env, low traffic        | ~$35            |
| CloudWatch Logs      | ~1 GB/month                   | ~$0.50          |
| S3 (Terraform state) | Minimal                       | ~$0.01          |
| **Total (per env)**  |                               | **~$69/month**  |

> For all 3 environments running simultaneously: ~$207/month. Use [AWS Pricing Calculator](https://calculator.aws) for exact estimates.
