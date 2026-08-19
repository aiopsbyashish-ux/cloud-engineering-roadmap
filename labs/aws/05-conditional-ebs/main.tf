module "web_server" {
  source = "./modules/ec2"

  project_name  = var.project_name
  instance_name = var.instance_name

  ami_id        = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  root_volume_size = var.root_volume_size

  subnet_id          = aws_subnet.public.id
  security_group_ids = [aws_security_group.public.id]

  associate_public_ip_address = var.associate_public_ip_address
  enable_detailed_monitoring  = var.enable_detailed_monitoring
  application_volume_size     = var.application_volume_size
  user_data                   = file("${path.module}/user-data.sh")
}