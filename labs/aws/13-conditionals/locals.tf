locals {
  resource_tier = var.environment == "prod" ? "critical" : "standard"
}