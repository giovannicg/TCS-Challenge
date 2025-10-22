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
├── app/                      # Aplicación
│   ├── src/
│   │   ├── main.py           # FastAPI app
│   │   └── auth.py           # Autenticación
│   ├── test/
│   │   └── test_devops.py    # Pruebas
│   ├── Dockerfile            # Container
│   └── requirements.txt      # Dependencias
├── infra/
│   └── terraform/            # Infraestructura (modular)
│       ├── modules/
│       │   └── app_environment/
│       │       ├── main.tf       # AKS, ACR, KeyVault, APIM
│       │       ├── variables.tf
│       │       └── outputs.tf
│       └── environments/
│           ├── test/
│           │   ├── main.tf
│           │   └── test.tfvars
│           └── prod/
│               ├── main.tf
│               └── prod.tfvars
└── .github/workflows/       # CI/CD
    └── ci-cd.yml
```

## Instalación

### 1. Clonar repositorio
```bash
git clone https://github.com/tu-usuario/TCS-Challenge.git
cd TCS-Challenge
```

### 2. Backend de Terraform (opcional pero recomendado)
Crear Storage Account y Container si vas a usar backend remoto (ajusta nombres si cambiaste):
```bash
az group create -n rg-terraform-state -l "East US"
az storage account create -g rg-terraform-state -n stterraformstate211025 -l "East US" --sku Standard_LRS
az storage container create --name stterraformstate211025 --account-name stterraformstate211025
```

### 3. Desplegar infraestructura (entornos)

Test (1 nodo):
```bash
cd infra/terraform/environments/test
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

Prod (por límites de vCPU, recomendado 1 nodo; si tienes cuota, usa 2):
```bash
cd infra/terraform/environments/prod
terraform init
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

Notas importantes:
- La suscripción usada tiene límites bajos de vCPU e IPs públicas. Si recibes errores de cuota (vCPU o Public IP), reduce `aks_node_count` o usa SKUs más pequeños (ej. `Standard_B2s`).
- APIM se crea con `sku_name = "Consumption_0"` por defecto para minimizar costos.

### 4. Construir y publicar imagen (local)
```bash
cd app
docker build -t devops-app:latest .

# ACR del entorno (desde outputs)
# Test:
TEST_ACR=$(terraform -chdir=../../infra/terraform/environments/test output -raw acr_login_server)
docker tag devops-app:latest $TEST_ACR/devops-app:latest
az acr login --name ${TEST_ACR%%.*}
docker push $TEST_ACR/devops-app:latest

# Prod (similar):
PROD_ACR=$(terraform -chdir=../../infra/terraform/environments/prod output -raw acr_login_server)
docker tag devops-app:latest $PROD_ACR/devops-app:latest
az acr login --name ${PROD_ACR%%.*}
docker push $PROD_ACR/devops-app:latest
```

### 5. Conectar a AKS
```bash
# Test
az aks get-credentials -g $(terraform -chdir=infra/terraform/environments/test output -raw resource_group_name) \
  -n $(terraform -chdir=infra/terraform/environments/test output -raw aks_cluster_name) --overwrite-existing

# Prod
az aks get-credentials -g $(terraform -chdir=infra/terraform/environments/prod output -raw resource_group_name) \
  -n $(terraform -chdir=infra/terraform/environments/prod output -raw aks_cluster_name) --overwrite-existing
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
- `*.tfvars` con secretos (ej. `test.tfvars`, `prod.tfvars`)
- `config.env` (si lo usas localmente)
- `terraform.tfstate*` (estado local)

**Archivos de ejemplo incluidos:**
- `secrets.tfvars.example` - Plantilla para secretos
- `terraform.tfvars.example` - Plantilla para variables

**Comandos seguros:**
```bash
# Usar archivo por entorno
terraform apply -var-file=test.tfvars
terraform apply -var-file=prod.tfvars

# O usar variables de entorno
export TF_VAR_jwt_secret_value="tu-secreto"
export TF_VAR_api_key_value="tu-api-key"
terraform apply -var-file=test.tfvars
```

**Para la aplicación:**
Los secretos (`api-key`, `jwt-secret`) se almacenan en Azure Key Vault y se inyectan vía Workload Identity en AKS. No es necesario commitear secretos.

## Autor

Giovanni Capote