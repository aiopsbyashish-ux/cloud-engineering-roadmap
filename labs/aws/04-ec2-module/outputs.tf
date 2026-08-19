output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.web_server.instance_id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.web_server.private_ip
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.web_server.public_ip
}