# environments/prod/prod.tfvars
# ¡¡AÑADE ESTE ARCHIVO A .gitignore!!

env_name       = "prod"
aks_node_count = 1 # Mínimo 2 nodos para alta disponibilidad
aks_vm_sku     = "Standard_DC2s_v3" # SKU más robusto para prod

kubernetes_namespace            = "prod"
kubernetes_service_account_name = "devops-app-sa"

# Valores de los secretos (usar GitHub Secrets en el pipeline)
api_key_value    = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
jwt_secret_value = "un-secreto-jwt-diferente-y-mas-fuerte-para-prod"