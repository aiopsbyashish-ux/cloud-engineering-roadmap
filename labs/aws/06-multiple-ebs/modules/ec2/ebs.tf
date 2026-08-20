resource "aws_ebs_volume" "additional" {
  for_each = var.additional_volumes

  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-${each.key}-volume"
  }
}