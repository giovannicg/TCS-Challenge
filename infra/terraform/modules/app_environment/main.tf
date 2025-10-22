# modules/app_environment/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

# 1. Grupo de Recursos
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.env_name}-devops-app"
  location = var.location
  tags = {
    environment = var.env_name
  }
}

# 2. Container Registry (ACR)
resource "azurerm_container_registry" "acr" {
  name                = "acr${replace(var.env_name, "-", "")}devopsapp" # Nombres únicos
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

# 3. Identidad Administrada para la App
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-${var.env_name}-devops-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# 4. Key Vault y Secretos
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.env_name}-devops-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  soft_delete_retention_days = 7

  # Dar permisos al usuario actual
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge", "Recover"
    ]
  }

  # Dar permisos a la Identidad Administrada
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.app_identity.principal_id

    secret_permissions = [
      "Get", "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = var.api_key_value
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = var.jwt_secret_value
  key_vault_id = azurerm_key_vault.kv.id
}

# 5. Clúster de Kubernetes (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-${var.env_name}-devops-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "dns-${var.env_name}"
  
  oidc_issuer_enabled = true # Requerido para Workload Identity
  
  default_node_pool {
    name       = "default"
    node_count = var.aks_node_count
    vm_size    = var.aks_vm_sku
  }

  identity {
    type = "SystemAssigned"
  }
  
  # Conectar AKS con ACR
  role_based_access_control_enabled = true
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# 6. Credencial Federada (Workload Identity)
resource "azurerm_federated_identity_credential" "fic" {
  name                = "fic-${var.env_name}-devops-app"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.app_identity.id
  subject             = "system:serviceaccount:${var.kubernetes_namespace}:${var.kubernetes_service_account_name}"
}

# 7. API Management
resource "azurerm_api_management" "apim" {
  name                = "apim-${var.env_name}-devops-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = "DevOps Candidate"
  publisher_email     = "admin@example.com"
  
  # Usar "Consumption" para todos los entornos (más económico)
  sku_name = "Consumption_0"
}