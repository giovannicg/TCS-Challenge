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
│   └── requirements.txt   # Dependencias
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

### 2. Desplegar infraestructura
```bash
cd infra/terraform
terraform init
terraform apply
```

### 3. Construir aplicación
```bash
cd app
docker build -t devops-microservice .
```

## Uso del API

### Endpoint Principal

**POST** `/DevOps`

```bash
curl -X POST \
  -H "X-Parse-REST-API-Key: 2f5ae96c-b558-4c7b-a590-a501ae1c3f6c" \
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

- **API Key**: `2f5ae96c-b558-4c7b-a590-a501ae1c3f6c`
- **JWT**: Algoritmo HS256 con expiración

## Autor

Giovanni Capote