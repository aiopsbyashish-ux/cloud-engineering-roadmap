resource "aws_s3_bucket" "drift_demo" {
  bucket = "ashish-jain-drift-demo-2026"

  tags = {
    Name = "terraform drift demo"
  }

  lifecycle {
    ignore_changes = [
      tags["Name"]
    ]
    prevent_destroy = false
  }

}
resource "aws_s3_bucket" "import_demo" {
  bucket = "ashish-jain-import-demo-2026"

}