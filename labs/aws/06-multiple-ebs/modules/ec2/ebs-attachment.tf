resource "aws_volume_attachment" "additional" {
  for_each = var.additional_volumes

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.this.id
}