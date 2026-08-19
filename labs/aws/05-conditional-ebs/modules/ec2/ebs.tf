resource "aws_ebs_volume" "application" {
  count = var.application_volume_size != null ? 1 : 0

  availability_zone = aws_instance.this.availability_zone
  size              = var.application_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-app-volume"
  }
}