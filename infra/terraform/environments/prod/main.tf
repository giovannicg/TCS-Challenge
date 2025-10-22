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
