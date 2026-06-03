# =============================================================================
# Terraform Backend Configuration - S3 with Native Locking
# =============================================================================

terraform {
  backend "s3" {
    bucket       = "central-tfstate-estanix-871696174477"
    key          = "un-cloud-course-1"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}