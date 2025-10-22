# DevOps Microservice - TCS Challenge

## Descripción

Microservicio DevOps simple que cumple con los requisitos del desafío TCS. Construido con FastAPI, containerizado con Docker, y desplegado en Azure.

## Características

- ✅ **Endpoint REST `/DevOps`** con método POST
- ✅ **Autenticación**: API Key + JWT
- ✅ **Containerización** con Docker
- ✅ **Infraestructura** con Terraform
- ✅ **Load balancer** Azure
- ✅ **Pipeline CI/CD** con GitHub Actions
- ✅ **Pruebas automáticas**

## Estructura del Proyecto

```
TCS-Challenge/
├── app/                    # Aplicación
│   ├── src/
│   │   ├── main.py        # FastAPI app
│   │   └── auth.py        # Autenticación
│   ├── test/
│   │   └── test_devops.py # Pruebas
│   ├── Dockerfile         # Container
│   ├── requirements.txt   # Dependencias
│   └── config.env         # Configuración
├── infra/                 # Infraestructura
│   └── terraform/
│       ├── main.tf
│       └── variables.tf
└── .github/workflows/     # CI/CD
    └── ci-cd.yml
```

## Instalación

### 1. Clonar repositorio
```bash
git clone https://github.com/tu-usuario/TCS-Challenge.git
cd TCS-Challenge
```

### 2. Configurar secretos
```bash
cd infra/terraform
# Copiar archivo de ejemplo
cp secrets.tfvars.example secrets.tfvars
# Editar con tus valores secretos
nano secrets.tfvars
```

### 3. Desplegar infraestructura
```bash
terraform init
terraform apply -var-file="secrets.tfvars"
```

### 3. Configurar variables
```bash
cd app
# Editar config.env con tus valores
nano config.env
```

### 4. Construir y desplegar aplicación
```bash
# Construir imagen
docker build -t devops-microservice .

# Obtener ACR login server
ACR_SERVER=$(terraform output -raw container_registry_login_server)

# Tag para ACR
docker tag devops-microservice:latest $ACR_SERVER/devops-microservice:latest

# Push a ACR
az acr login --name $ACR_SERVER
docker push $ACR_SERVER/devops-microservice:latest

# Conectar a AKS
az aks get-credentials --resource-group devops-microservice-rg-devel --name devops-devel-aks

# Desplegar secrets y aplicación
kubectl apply -f app/k8s/secret.yaml
kubectl apply -f app/k8s/deployment.yaml
```

## Uso del API

### Endpoint Principal

**POST** `/DevOps`

```bash
curl -X POST \
  -H "X-Parse-REST-API-Key: ${API_KEY}" \
  -H "X-JWT-KWY: ${JWT}" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45
  }' \
  https://${HOST}/DevOps
```

**Respuesta:**
```json
{
  "message": "Hello Juan Perez your message will be send"
}
```

## Pruebas

```bash
cd app
pip install -r requirements.txt
pytest test/
```

## Seguridad

- **API Key**: Configurable en `config.env`
- **JWT Secret**: Almacenado en Azure Key Vault
- **Autenticación**: Managed Identity de AKS
- **Sin secretos hardcodeados**: Todo en Key Vault

### Manejo de Secretos

**Archivos que NO se suben a Git:**
- `secrets.tfvars` - Secretos de Terraform
- `config.env` - Variables de la aplicación
- `terraform.tfvars` - Variables personalizadas

**Archivos de ejemplo incluidos:**
- `secrets.tfvars.example` - Plantilla para secretos
- `terraform.tfvars.example` - Plantilla para variables

**Comandos seguros:**
```bash
# Opción 1: Usar archivo de secretos
terraform apply -var-file="secrets.tfvars"

# Opción 2: Usar variables de entorno
export TF_VAR_jwt_secret="tu-secreto"
terraform apply

# Opción 3: Usar archivo de variables personalizado
terraform apply -var-file="terraform.tfvars"
```

**Para la aplicación:**
```bash
# Configurar variables de entorno
export ALLOWED_API_KEY="tu-api-key"
export JWT_SECRET="tu-jwt-secret"
export AZURE_KEY_VAULT_URL="https://tu-keyvault.vault.azure.net/"

# O usar archivo config.env
source app/config.env
```

## Autor

Giovanni Capote