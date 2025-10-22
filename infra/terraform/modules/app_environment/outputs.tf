# modules/app_environment/outputs.tf

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "key_vault_url" {
  value = azurerm_key_vault.kv.vault_uri
}

output "app_identity_client_id" {
  description = "El Client ID de la identidad de la app para Workload Identity"
  value       = azurerm_user_assigned_identity.app_identity.client_id
}