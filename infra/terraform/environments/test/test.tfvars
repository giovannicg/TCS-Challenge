# environments/test/test.tfvars
# ¡¡AÑADE ESTE ARCHIVO A .gitignore!!

# Variables básicas
env_name = "test"

# Configuración de AKS
aks_node_count = 1
aks_vm_sku     = "Standard_DC2s_v3" 

# Configuración de Kubernetes
kubernetes_namespace            = "test"
kubernetes_service_account_name = "devops-app-sa"

# --- CORRECCIÓN AQUÍ ---
# Los nombres deben coincidir con los de main.tf
api_key_value    = "2f5ae96c-b558-4c7b-a590-a501ae1c3f6c"
jwt_secret_value = "mi-secreto-jwt-para-test"