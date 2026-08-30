resource "aws_s3_bucket" "map_demo" {
  for_each = var.environments

  bucket = "ashish-jain-map-${each.key}-2026"

  tags = {
    Name        = "map-demo-${each.key}"
    Description = each.value
  }
}