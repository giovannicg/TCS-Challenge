variable "env_name" {
  type = string
  default = "prod"
}
variable "aks_node_count" {
  type = number
  default = 2
}
variable "aks_vm_sku" {
  type = string
  default = "Standard_DC2s_v3"
}
variable "api_key_value" {
  type = string
  sensitive = true
}
variable "jwt_secret_value" {
  type = string
  sensitive = true
}
variable "kubernetes_namespace" {
  type = string
  default = "prod"
}
variable "kubernetes_service_account_name" {
  type = string
  default = "devops-app-sa"
}