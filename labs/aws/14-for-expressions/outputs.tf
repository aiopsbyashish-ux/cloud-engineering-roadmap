output "server_names" {
  description = "Generated server names"
  value       = local.server_names
}

output "non_db_server_names" {
  description = "Generated server names excluding database server"
  value       = local.non_db_server_names
}