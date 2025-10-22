# modules/app_environment/variables.tf

variable "env_name" {
  description = "El nombre del entorno (ej. 'test' o 'prod')"
  type        = string
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "East US"
}

variable "aks_node_count" {
  description = "Número de nodos para el clúster de AKS"
  type        = number
}

variable "aks_vm_sku" {
  description = "El SKU (tamaño) de las VMs para los nodos de AKS"
  type        = string
}

variable "api_key_value" {
  description = "El valor del API Key a guardar en Key Vault"
  type        = string
  sensitive   = true
}

variable "jwt_secret_value" {
  description = "El valor del Secreto JWT a guardar en Key Vault"
  type        = string
  sensitive   = true
}

variable "kubernetes_namespace" {
  description = "El namespace de K8s donde correrá la app (ej. 'test' o 'prod')"
  type        = string
}

variable "kubernetes_service_account_name" {
  description = "El nombre del ServiceAccount de K8s que usará la app"
  type        = string
  default     = "devops-app-sa"
}