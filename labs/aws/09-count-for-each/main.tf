resource "aws_s3_bucket" "count_demo" {
  count = 3

  bucket = "ashish-jain-count-demo-${count.index}-2026"

  tags = {
    Name = "count_demo-${count.index}"
  }
}

resource "aws_s3_bucket" "foreach_demo" {
  for_each = toset(var.environments)

  bucket = "ashish-jain-foreach-demo-${each.key}-2026"

  tags = {
    Name = "foreach_demo-${each.key}"
  }
}