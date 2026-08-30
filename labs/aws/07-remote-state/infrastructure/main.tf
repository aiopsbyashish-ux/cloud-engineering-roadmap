resource "aws_s3_bucket" "demo" {
  bucket = "ashish-jain-remote-state-demo-2026"

  tags = {
    Name = "Remote State Demo"
 Purpose = "State Lock Testing"
  }
}