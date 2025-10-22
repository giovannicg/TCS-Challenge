variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "devops-microservice-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
}
variable "api-key" {
  description = "api-key"
  type = string
  sensitive = true
}