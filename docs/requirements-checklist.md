# NexaCloud Project - Requirements Checklist

> **Purpose:** Verify that the deployed infrastructure meets every requirement stated in `SPECS.md` before declaring the project done.
> **How to use:** Walk through each item. Mark ✅ (verified, working), ⚠️ (partial / needs review), or ❌ (missing / broken).

---

## 1. Web Page (Company Name) — EC2, SSH

**Requirement:** A simple HTML page served from EC2 that displays the company name.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 1.1 | At least one EC2 instance is running | `aws ec2 describe-instances --filters "Name=tag:Project,Values=nexacloud" --query "Reservations[].Instances[].State.Name"` | 🆗 |
| 1.2 | EC2 hosts a web server (nginx) serving the company name | `curl http://<ALB_PUBLIC_IP>/` returns HTML with "NexaCloud" | 🆗 |
| 1.3 | EC2 is part of an Auto Scaling Group (ASG) | `aws autoscaling describe-auto-scaling-groups` | 🆗 |
| 1.4 | SSH access works on non-default port (2222) | `ssh -i key.pem -p 2222 ec2-user@<EC2_PUBLIC_IP>` | 🆗 |
| 1.5 | Port 22 is **closed** in the Security Group | `aws ec2 describe-security-groups --query "SecurityGroups[].IpPermissions[?FromPort==\`22\`]"` returns empty | 🆗 |
| 1.6 | EC2 `user_data.sh` reconfigures `sshd` to listen on 2222 | SSH into instance → `sudo ss -tlnp \| grep 2222` shows sshd | 🆗 |

---

## 2. Database Data — RDS, Security Groups, VPC

**Requirement:** Display DB data in the web app. DDL and seed data provided by NexaCloud. External connection on port **9876**.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 2.1 | RDS PostgreSQL instance exists and is `available` | `aws rds describe-db-instances --query "DBInstances[?DBInstanceIdentifier=='nexacloud-postgres'].DBInstanceStatus"` | 🆗 |
| 2.2 | RDS listens on port **9876** (not default 5432) | `aws rds describe-db-instances --query "DBInstances[].Endpoint.Port"` shows `9876` | 🆗 |
| 2.3 | RDS engine version is valid in the chosen region (PostgreSQL 16.x for `us-east-1`) | `terraform plan` succeeds with no `InvalidParameterCombination` | 🆗 |
| 2.4 | Database `nexaclouddb` is created on first boot | `psql -h <RDS_ENDPOINT> -p 9876 -U nexacloud_admin -d nexaclouddb -c "\l"` | 🆗 |
| 2.5 | The `estudiante` table is created and populated with seed data | `psql ... -c "SELECT COUNT(*) FROM estudiante;"` returns > 0 | 🆗 |
| 2.6 | RDS Security Group allows inbound on 9876 from app subnets only | `aws ec2 describe-security-groups` review | 🆗 |
| 2.7 | RDS is in a private subnet (not directly reachable from internet) | RDS is in `private_1` / `private_2` subnets | 🆗 |
| 2.8 | The web app (Tab 2) successfully displays DB data | Open app, navigate to DB tab, see list of students | 🆗 |

---

## 3. Bucket Images — S3, Lambda, API Gateway, VPC

**Requirement:** Display employee images served from S3 via Lambda + API Gateway.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 3.1 | S3 bucket exists with a unique name (account-suffix) | `aws s3 ls \| grep nexacloud` | 🆗 |
| 3.2 | S3 bucket has **public access blocked** | `aws s3api get-public-access-block --bucket <BUCKET>` returns `BlockPublicAcls=true, IgnorePublicAcls=true, BlockPublicPolicy=true, RestrictPublicBuckets=true` | 🆗 |
| 3.3 | S3 bucket policy does NOT contain a blanket `Deny` that overrides the Lambda IAM Allow | Review `s3-bucket-policy.tf` — `aws:PrincipalAccount` excludes own account | 🆗 |
| 3.4 | Images are uploaded to the bucket (`employee-images/` prefix) | `aws s3 ls s3://<BUCKET>/employee-images/` returns files | 🆗 |
| 3.5 | `serve-images` Lambda is deployed and has correct env vars | `aws lambda get-function-configuration --function-name nexacloud-serve-images` | 🆗 |
| 3.6 | Lambda has IAM permission to `s3:GetObject` on the bucket | `aws iam get-role-policy --role-name nexacloud-lambda-images-role` | 🆗 |
| 3.7 | Lambda ZIP includes `node_modules` (no `Cannot find module '@aws-sdk/...'`) | `unzip -l serve_images_lambda.zip \| grep node_modules` | 🆗 |
| 3.8 | API Gateway GET `/images` returns presigned URLs | `curl https://<API_ID>.execute-api.us-east-1.amazonaws.com/prod/images` | 🆗 |
| 3.9 | The web app (Tab 3) successfully displays the images | Open app, navigate to images tab, see all images | 🆗 |

---

## 4. Lambda Function (Insert Student) — Lambda, API Gateway

**Requirement:** A button triggers an API Gateway → Lambda flow that inserts team members into the `estudiantes` table.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 4.1 | `insert-student` Lambda is deployed | `aws lambda get-function --function-name nexacloud-insert-student` | 🆗 |
| 4.2 | Lambda env vars include `DB_HOST` (hostname **only**, no port) | `aws lambda get-function-configuration ... --query "Environment.Variables"` | 🆗 |
| 4.3 | Lambda ZIP includes `node_modules` (no `Cannot find module 'pg'`) | `unzip -l insert_student_lambda.zip \| grep node_modules` | 🆗 |
| 4.4 | Lambda IAM role has `rds-db:connect` permission (or direct DB password is provided) | `aws iam get-role-policy ...` | 🆗 |
| 4.5 | Lambda can reach RDS (VPC subnets + SG allow egress) | `aws lambda invoke --function-name nexacloud-insert-student --payload '{}' response.json` | 🆗 |
| 4.6 | API Gateway POST `/estudiante` is configured with API Key required | `aws apigateway get-method --rest-api-id <ID> --resource-id <RES> --http-method POST` shows `apiKeyRequired=true` | 🆗 |
| 4.7 | API Key is provisioned and the app uses it | `aws apigateway get-api-keys` returns at least one key | 🆗 |
| 4.8 | The web app (Tab 4) successfully inserts students into the DB | Click the button → `SELECT * FROM estudiante` shows new rows |🆗 |

---

## 5. Monitoring and Alerts — CloudWatch, SNS

**Requirement:** Monitor services and trigger alerts on threshold breaches or specific events.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 5.1 | CloudWatch dashboard exists for the project | `aws cloudwatch list-dashboards` | 🆗 |
| 5.2 | CloudWatch log groups exist for Lambda, API Gateway, EC2, ALB | `aws logs describe-log-groups` | 🆗 |
| 5.3 | Alarms are defined (e.g. RDS CPU, ASG instance count, 5xx ALB) | `aws cloudwatch describe-alarms` | 🆗 |
| 5.4 | SNS topic exists for alerts | `aws sns list-topics` | 🆗 |
| 5.5 | SNS subscription is confirmed (email accepted) | `aws sns list-subscriptions-by-topic --topic-arn <ARN>` shows `ConfirmationStatus=Confirmed` | 🆗 |
| 5.6 | At least one alarm is in `OK` or `IN_ALARM` state (not `INSUFFICIENT_DATA`) | `aws cloudwatch describe-alarms --state-value-equals OK` (after a few minutes of data) | 🆗 |
| 5.7 | The web app (Tab 5) shows the monitoring dashboard | Open app, navigate to monitoring tab, see metrics | 🆗 |

---

## 6. Load Balancer — ELB, EC2

**Requirement:** A page that reloads constantly, served by a load balancer, with the server ID in the response header. Multiple EC2 instances behind it; possible to scale manually.

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| 6.1 | Application Load Balancer exists | `aws elbv2 describe-load-balancers` | 🆗 |
| 6.2 | ALB target group has at least 2 healthy targets | `aws elbv2 describe-target-health` shows 2+ `healthy` | 🆗 |
| 6.3 | ALB has a listener on port 80 (or 443) | `aws elbv2 describe-listeners --load-balancer-arn <ARN>` | 🆗 |
| 6.4 | EC2 instances respond with their unique identifier in a response header | `curl -I http://<ALB_DNS>/` shows a custom header with the instance ID | 🆗 |
| 6.5 | ASG desired capacity can be increased manually | `aws autoscaling update-auto-scaling-group --auto-scaling-group-name ... --desired-capacity 4` succeeds and a new instance joins | 🆗 |
| 6.6 | The web app (Tab 6) loads the ALB page inside an iframe | Open app, navigate to load balancer tab, see content | 🆗 |

---

## Security & Best Practices (Cross-Cutting)

| # | Check | How to verify | Status |
|---|-------|---------------|--------|
| S.1 | API Gateway requires an API Key for both endpoints | Tab 3 + Tab 4: `aws apigateway get-method` shows `apiKeyRequired=true` | 🆗 |
| S.2 | API Gateway has a usage plan attached to the key | `aws apigateway get-usage-plans` | 🆗 |
| S.3 | No S3 bucket is public | `aws s3api get-public-access-block --bucket <BUCKET>` (all four flags true) | 🆗|
| S.4 | No security group allows `0.0.0.0/0` on port 22 | `aws ec2 describe-security-groups --query "SecurityGroups[?IpPermissions[?FromPort==\`22\`]]"` returns empty | 🆗 |
| S.5 | No security group allows `0.0.0.0/0` on RDS port 9876 | Same query for port `9876` | 🆗 |
| S.6 | RDS `storage_encrypted = true` | `aws rds describe-db-instances --query "DBInstances[].StorageEncrypted"` | 🆗 |
| S.7 | RDS `publicly_accessible = false` (or controlled) | `aws rds describe-db-instances --query "DBInstances[].PubliclyAccessible"` | 🆗 |
| S.8 | Lambda env vars do not contain hardcoded secrets in source code | Search `lambda/**/*.js` for `password` / `secret` — should be empty | 🆗 |
| S.9 | Terraform state backend is encrypted | Backend `encrypt = true` | 🆗 |
| S.10 | All resources tagged with `Project`, `Environment`, `ManagedBy` | `aws resourcegroupstaggingapi get-resources --tag-filters ...` | 🆗 |

---

## Deliverables (Documentation)

| # | Deliverable | File | Status |
|---|-------------|------|--------|
| D.1 | Architecture report with network topology diagram | `docs/architecture-report.md` | ☐ |
| D.2 | Cost estimation report for the next 6 months | `docs/cost-estimation-6months.md` | ☐ |
| D.3 | Step-by-step deployment guide in README | `README.md` | ☐ |
| D.4 | Project specs reference | `SPECS.md` | 🆗 |
| D.5 | This requirements checklist | `docs/requirements-checklist.md` | 🆗 |

---

## End-to-End Smoke Test

After all sections above pass, run a full smoke test:

1. **Open the app:** `https://<ALB_DNS>/` → Tab 1 (company name visible)
2. **Tab 2:** DB listing → see all seeded students
3. **Tab 3:** Images tab → all images load (click a few to verify presigned URLs work)
4. **Tab 4:** Click "Insert student" → confirm new row in DB:
   ```bash
   psql -h <RDS> -p 9876 -U nexacloud_admin -d nexaclouddb \
     -c "SELECT * FROM estudiante ORDER BY created_at DESC LIMIT 5;"
   ```
5. **Tab 5:** Monitoring dashboard renders
6. **Tab 6:** Load balancer iframe loads; reload several times; the server ID in the header changes
7. **Trigger an alarm:** `aws cloudwatch set-alarm-state --alarm-name <...> --state-value ALARM --state-reason "test"` → confirm SNS email received
8. **Scale manually:** `aws autoscaling update-auto-scaling-group --desired-capacity 3` → wait, then check ALB target group now has 3 healthy targets

---

## Project Status

- [x] All section 1 checks pass
- [x] All section 2 checks pass
- [x] All section 3 checks pass
- [x] All section 4 checks pass
- [x] All section 5 checks pass
- [x] All section 6 checks pass
- [x] All security best practices pass
- [x] All deliverables exist
- [x] End-to-end smoke test passes

**When all of the above are checked, the project is considered done.**
