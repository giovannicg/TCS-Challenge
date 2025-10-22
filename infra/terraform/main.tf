# Simple Azure infrastructure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}
locals {
  env_suffix = terraform.workspace
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-${local.env_suffix}"
  location = var.location
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "${var.project_name}-${local.env_suffix}-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "${var.project_name}-${local.env_suffix}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackEndAddressPool"
}

# Health Probe
resource "azurerm_lb_probe" "hp" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "HealthProbe"
  port            = 8080
  protocol        = "Http"
  request_path    = "/health"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lbr" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8080
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bap.id]
  probe_id                       = azurerm_lb_probe.hp.id
}

# Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "${var.project_name}${local.env_suffix}acr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Virtual Network for AKS
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.project_name}-${local.env_suffix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for AKS
resource "azurerm_subnet" "aks_subnet" {
  name                 = "${var.project_name}-${local.env_suffix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# AKS Cluster with Workload Identity enabled
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.project_name}-${local.env_suffix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.project_name}-${local.env_suffix}"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_E2as_v5"
    vnet_subnet_id  = azurerm_subnet.aks_subnet.id
    os_disk_type    = "Managed"
}

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

  # Enable Workload Identity
  workload_identity_enabled = true
  oidc_issuer_enabled = true

}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "${var.project_name}-${local.env_suffix}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
  }

  # Access policy for AKS managed identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

    secret_permissions = [
      "Get",
      "List"
    ]
  }
}

# API Key in Key Vault
resource "azurerm_key_vault_secret" "api_key" {
  name         = "api-key"
  value        = var.api-key
  key_vault_id = azurerm_key_vault.kv.id
}

# JWT Secret in Key Vault
resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = "jwt-secret"
  value        = var.jwt_secret
  key_vault_id = azurerm_key_vault.kv.id
}

# Current client config
data "azurerm_client_config" "current" {}

# User Assigned Identity for Workload Identity
resource "azurerm_user_assigned_identity" "workload_identity" {
  name                = "${var.project_name}-${local.env_suffix}-workload-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Role assignment for Key Vault access
resource "azurerm_role_assignment" "key_vault_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload_identity.principal_id
}

# Federated identity credential
resource "azurerm_federated_identity_credential" "workload_identity" {
  name                = "${var.project_name}-${local.env_suffix}-federated-credential"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload_identity.id
  subject             = "system:serviceaccount:default:devops-workload-identity"
}

# Outputs
output "load_balancer_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "container_registry_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "aks_cluster_endpoint" {
  value = azurerm_kubernetes_cluster.aks.kube_config.0.host
}

output "key_vault_uri" {
  value = azurerm_key_vault.kv.vault_uri
}

output "workload_identity_client_id" {
  value = azurerm_user_assigned_identity.workload_identity.client_id
}

output "workload_identity_tenant_id" {
  value = azurerm_user_assigned_identity.workload_identity.tenant_id
}
