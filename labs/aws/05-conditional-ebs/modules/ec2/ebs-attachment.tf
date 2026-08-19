resource "aws_volume_attachment" "application" {
  count = var.application_volume_size != null ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.application[0].id
  instance_id = aws_instance.this.id
}