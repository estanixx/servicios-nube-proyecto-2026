# NexaCloud AWS Infrastructure - 6-Month Cost Estimation

> **Document Version**: 1.0  
> **Last Updated**: 2026-05-29  
> **Project**: NexaCloud AWS Infrastructure Migration

---

## Executive Summary

This document provides a comprehensive 6-month cost estimation for the NexaCloud AWS infrastructure deployment. The total estimated cost is **$720.23** for a 6-month pilot period, with NAT Gateway representing the largest expense at $388.80 (54% of total cost).

---

## Assumptions

| Assumption | Value |
|-----------|-------|
| Region | us-east-1 (N. Virginia) |
| Currency | USD |
| Pricing Model | On-demand (no Reserved Instances for pilot) |
| Free Tier | Deducted where applicable |
| Billing Cycle | Monthly |

---

## Service Cost Breakdown

### EC2 (t3.micro × 2, On-Demand)

| Item | Value |
|------|-------|
| Instance Type | t3.micro |
| Instance Count | 2 |
| Hourly Rate | $0.0104 |
| Hours/Month | 720 |
| Instance-Hours/Month | 1,440 |
| **Monthly Cost** | **$14.98** |
| **6-Month Total** | **$89.88** |

### RDS PostgreSQL (db.t3.micro, Multi-AZ)

| Item | Value |
|------|-------|
| Instance Type | db.t3.micro |
| Deployment | Multi-AZ |
| Hourly Rate | $0.0174 |
| Multi-AZ Multiplier | 2× |
| Monthly Cost | $12.53 |
| **6-Month Total** | **$75.18** |

> **Note**: Multi-AZ pricing is effectively 2× single-AZ pricing for db.t3.micro.

### S3 Storage

| Item | Value |
|------|-------|
| Storage | 1 GB employee images |
| Storage Rate (gp3) | $0.023/GB |
| Monthly Storage Cost | $0.023 |
| GET Requests/Month | 1,000 |
| GET Rate | $0.0004/1,000 requests |
| Monthly Request Cost | $0.0004 |
| **Monthly Total** | **$0.0234** |
| **6-Month Total** | **$0.14** |

### Lambda Functions

| Function | Invocations/Day | Monthly Invocations | Cost |
|----------|-----------------|---------------------|------|
| insertStudentLambda | 100 | 3,000 | $0.0008 |
| getEmployeeImagesLambda | 500 | 15,000 | $0.004 |
| **Monthly Total** | | **18,000** | **$0.0048** |
| **6-Month Total** | | | **$0.03** |

> **Note**: Lambda pricing includes free tier (400,000 GB-seconds/month). Costs shown are for compute only.

### API Gateway

| Item | Value |
|------|-------|
| API Type | REST API |
| Free Tier | 1 million requests/month |
| Assumed Monthly Requests | 50,000 |
| Free Tier Status | Within free tier |
| API Key Charge | $5/key/month |
| Keys Required | 1 |
| **6-Month Total** | **$30.00** |

### NAT Gateway

| Item | Value |
|------|-------|
| NAT Gateways | 2 (HA - one per AZ) |
| Hourly Rate | $0.045/gateway |
| Hours/Month | 720 |
| **Monthly Cost** | **$64.80** |
| **6-Month Total** | **$388.80** |

> **⚠️ COST WARNING**: NAT Gateway is the largest expense at 54% of total infrastructure cost.

### Elastic Load Balancer (ALB)

| Item | Value |
|------|-------|
| ALB Hourly Rate | $0.0225 |
| Hours/Month | 720 |
| Monthly ALB Cost | $16.20 |
| LCU (estimated) | ~0.001 |
| LCU Cost | $5.80/LCU-hour |
| Monthly LCU Cost | ~$0.006 |
| **Monthly Total** | **$16.21** |
| **6-Month Total** | **$97.24** |

### CloudWatch

| Item | Value |
|------|-------|
| Dashboard | $3/dashboard/month |
| Alarms | 7 alarms × $0.10/month |
| Logs (estimated) | 1 GB/month × $0.033 |
| **Monthly Total** | **$6.03** |
| **6-Month Total** | **$36.20** |

### Data Transfer

| Item | Value |
|------|-------|
| AZ Transfer | 1 GB/month × $0.01 |
| Internet Egress (est.) | 5 GB/month × $0.09 |
| **Monthly Total** | **$0.46** |
| **6-Month Total** | **$2.76** |

---

## 6-Month Total Cost Summary

| Service | Monthly Cost | 6-Month Cost | % of Total |
|---------|--------------|--------------|------------|
| EC2 | $14.98 | $89.88 | 12.5% |
| RDS (Multi-AZ) | $12.53 | $75.18 | 10.4% |
| S3 | $0.02 | $0.14 | <0.1% |
| Lambda | $0.005 | $0.03 | <0.1% |
| API Gateway | $5.00 | $30.00 | 4.2% |
| NAT Gateway | $64.80 | $388.80 | **54.0%** |
| ALB | $16.21 | $97.24 | 13.5% |
| CloudWatch | $6.03 | $36.20 | 5.0% |
| Data Transfer | $0.46 | $2.76 | 0.4% |
| **TOTAL** | | **$720.23** | **100%** |

---

## Cost Optimization Recommendations

### 🔴 High Priority (Major Savings)

#### 1. Reduce NAT Gateway Costs
**Potential Savings**: Up to $194.40 (27% of total)

NAT Gateway at $64.80/month is 54% of total infrastructure cost. Consider:

| Strategy | Implementation | Savings |
|----------|----------------|---------|
| VPC Endpoints for S3 | Add S3 VPC Gateway Endpoint | ~$40/month |
| Lambda in VPC | Use Lambda VPC config for S3 | Partial NAT reduction |
| VPC Interface Endpoints | PrivateLink for AWS services | Variable |

**Recommendation**: Implement S3 VPC Gateway Endpoint first - it routes S3 traffic through AWS internal network instead of NAT, eliminating NAT charges for S3 traffic.

#### 2. Reserve Instances (After Pilot)
**Potential Savings**: 30-60% on EC2 and RDS

Reserved Instances require 1-year or 3-year commitment but offer significant discounts:
- t3.micro Reserved (1-year, no upfront): ~$0.006/hour vs $0.0104 on-demand
- db.t3.micro Reserved (1-year, no upfront): ~$0.010/hour vs $0.0174 on-demand

### 🟡 Medium Priority

#### 3. Enable S3 Intelligent-Tiering
For employee images that are not frequently accessed, move to S3 Intelligent-Tiering:
- **Savings**: ~$0.01/month per GB for infrequently accessed data
- **Implementation**: Lifecycle rule after 90 days

#### 4. Review ALB Access Logs
ALB access logs are currently disabled. If enabling:
- Ensure S3 bucket lifecycle policies are configured
- Consider Athena for cost-efficient log analysis

### 🟢 Low Priority / Post-Pilot

#### 5. Consider Graviton Instances
After pilot, evaluate t4g.micro (ARM-based) for additional 10-20% savings.

#### 6. API Gateway Optimization
Currently using 1 API key at $5/month. If additional keys needed:
- Consider usage plan sharing across applications
- Evaluate if key is still necessary with Lambda authorizers

---

## Billing Alerts Recommendation

Set up billing alerts to monitor actual vs. projected costs:

| Alert Threshold | Action |
|-----------------|--------|
| $100/month | Warning notification |
| $130/month | Critical notification |
| Actual > 10% over projection | Investigate |

---

## Next Steps

1. **Immediate**: Deploy S3 VPC Endpoint to reduce NAT Gateway usage
2. **Month 1**: Review CloudWatch cost actuals vs. estimates
3. **Month 3**: Evaluate pilot success and consider Reserved Instances
4. **Month 6**: Full cost review and optimization before production scale

---

## References

- [AWS Pricing Calculator](https://calculator.aws/)
- [EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [RDS Pricing](https://aws.amazon.com/rds/postgresql/pricing/)
- [S3 Pricing](https://aws.amazon.com/s3/pricing/)
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [NAT Gateway Pricing](https://aws.amazon.com/vpc/pricing/)
- [CloudWatch Pricing](https://aws.amazon.com/cloudwatch/pricing/)
