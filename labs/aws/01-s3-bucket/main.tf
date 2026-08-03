resource "aws_s3_bucket" "terraform_lab" {
  bucket = var.bucket_name
}