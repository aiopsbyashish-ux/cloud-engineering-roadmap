locals {
  server_names = [for server in var.servers : "${server}-01"]

  non_db_server_names = [
    for server in var.servers : "${server}-01"
    if server != "db"
  ]
}