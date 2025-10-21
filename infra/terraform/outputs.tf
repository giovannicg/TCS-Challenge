# Output the load balancer public IP
output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.lb.ip_address
}

# Output the container registry login server
output "container_registry_login_server" {
  description = "Login server of the container registry"
  value       = azurerm_container_registry.main.login_server
}

# Output the Redis hostname
output "redis_hostname" {
  description = "Hostname of the Redis cache"
  value       = azurerm_redis_cache.main.hostname
}

# Output the Key Vault URI
output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Output the resource group name
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

# Output the load balancer frontend IP configuration
output "load_balancer_frontend_ip" {
  description = "Frontend IP configuration of the load balancer"
  value       = azurerm_lb.main.frontend_ip_configuration
}
