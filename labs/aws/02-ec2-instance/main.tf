resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  monitoring                  = var.enable_detailed_monitoring
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = file("${path.module}/user-data.sh")

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name = "${var.instance_name}-root-volume"
    }
  }

  tags = {
    Name = var.instance_name
  }
}