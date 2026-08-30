resource "aws_s3_bucket" "conditional_demo" {
  bucket = "ashish-jain-conditional-${var.environment}-2026"

  tags = {
    Name        = "conditional-demo-${var.environment}"
    Environment = var.environment
    Tier        = local.resource_tier
  }
}
resource "aws_s3_bucket" "audit" {
  count = var.environment == "prod" ? 1 : 0

  bucket = "ashish-jain-audit-${var.environment}-2026"

  tags = {
    Name        = "audit-${var.environment}"
    Environment = var.environment
    Purpose     = "Audit"
  }
}