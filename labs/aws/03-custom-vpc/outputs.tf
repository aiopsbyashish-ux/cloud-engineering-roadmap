output "vpc_id" {
  description = "ID of the custom VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}
output "web_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}