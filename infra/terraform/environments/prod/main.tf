# environments/prod/main.tf

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate211025"
    container_name       = "stterraformstate211025"
    key                  = "prod.devops-app.terraform.tfstate"
    subscription_id      = "ded1b755-72c7-459c-b999-8858e3dc0b83"
  }
}

module "app_environment" {
  source = "../../modules/app_environment"

  env_name                        = var.env_name
  aks_node_count                  = var.aks_node_count
  aks_vm_sku                      = var.aks_vm_sku
  api_key_value                   = var.api_key_value
  jwt_secret_value                = var.jwt_secret_value
  kubernetes_namespace            = var.kubernetes_namespace
  kubernetes_service_account_name = var.kubernetes_service_account_name
}

# Declaración de variables
variable "env_name" {
  type = string
}

variable "aks_node_count" {
  type = number
}

variable "aks_vm_sku" {
  type = string
}

variable "api_key_value" {
  type      = string
  sensitive = true
}

variable "jwt_secret_value" {
  type      = string
  sensitive = true
}

variable "kubernetes_namespace" {
  type = string
}

variable "kubernetes_service_account_name" {
  type = string
}
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