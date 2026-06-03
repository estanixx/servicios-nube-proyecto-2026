# =============================================================================
# S3 Upload Placeholder - Documentation for Future Image Uploads
# =============================================================================

# -----------------------------------------------------------------------------
# Documentation Resource
# Note: Actual employee images will be provided separately and uploaded via:
#   aws s3 cp ./employee-images/ s3://nexacloud-employee-images-us-east-1/employee-images/ --recursive
# -----------------------------------------------------------------------------

resource "null_resource" "s3_upload_documentation" {
  triggers = {
    bucket_name  = aws_s3_bucket.employee_images.bucket
    upload_guide = <<-EOT
      # S3 Employee Images Upload Guide

      ## Pre-requisites
      - AWS CLI configured with appropriate credentials
      - Images to upload in local directory

      ## Upload Command
      ```bash
      aws s3 cp ./employee-images/ s3://${aws_s3_bucket.employee_images.bucket}/employee-images/ --recursive
      ```

      ## Expected Image Structure
      ```
      employee-images/
      ├── photo1.jpg
      ├── photo2.jpg
      └── ...
      ```

      ## Access
      - Images are accessed via ServeImagesLambda (GET /images)
      - Pre-signed URLs are generated with 1-hour expiry
      - Images should be placed under employee-images/ prefix
    EOT
  }
}
