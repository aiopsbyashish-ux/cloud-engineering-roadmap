resource "aws_s3_bucket" "locals_demo" {
  bucket = "${local.name_prefix}-2026"

  tags = merge(
    local.common_tags,
    {
      Name = local.name_prefix
    }
  )
}