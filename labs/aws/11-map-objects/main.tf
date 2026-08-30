resource "aws_s3_bucket" "object_demo" {
  for_each = var.environment_config

  bucket = "ashish-jain-object-${each.key}-2026"

  tags = {
    Name        = "object-demo-${each.key}"
    Description = each.value.description
    Owner       = each.value.owner
    Critical    = tostring(each.value.critical)
  }
}