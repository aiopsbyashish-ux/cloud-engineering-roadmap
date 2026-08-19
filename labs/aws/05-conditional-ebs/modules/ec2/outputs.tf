output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}

output "application_volume_id" {
  description = "ID of the optional application EBS volume"
  value       = var.application_volume_size != null ? aws_ebs_volume.application[0].id : null
}