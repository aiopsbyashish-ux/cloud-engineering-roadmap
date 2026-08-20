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

output "additional_volume_ids" {
  description = "Map of additional EBS volume IDs"

  value = {
    for key, volume in aws_ebs_volume.additional :
    key => volume.id
  }
}