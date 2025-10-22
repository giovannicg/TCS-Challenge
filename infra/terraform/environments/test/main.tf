# environments/test/main.tf

terraform {
  # Configura un backend remoto para guardar el estado de Terraform
  # (Debes crear esta cuenta de almacenamiento primero)
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate211025"
    container_name       = "stterraformstate211025"
    key                  = "test.devops-app.terraform.tfstate"
    subscription_id      = "ded1b755-72c7-459c-b999-8858e3dc0b83"
  }
}

module "app_environment" {
  source = "../../modules/app_environment" # Apunta al módulo

  # Carga las variables desde el archivo .tfvars
  env_name                        = var.env_name
  aks_node_count                  = var.aks_node_count
  aks_vm_sku                      = var.aks_vm_sku
  api_key_value                   = var.api_key_value
  jwt_secret_value                = var.jwt_secret_value
  kubernetes_namespace            = var.kubernetes_namespace
  kubernetes_service_account_name = var.kubernetes_service_account_name
}
