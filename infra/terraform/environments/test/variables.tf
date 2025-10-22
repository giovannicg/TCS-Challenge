variable "env_name" {
  type = string
  default = "test"
}
variable "aks_node_count" {
  type = number
  default = 1
}
variable "aks_vm_sku" {
  type = string
  default = "Standard_B2s"
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
  default = "test"
}
variable "kubernetes_service_account_name" {
  type = string
  default = "devops-app-sa"
}