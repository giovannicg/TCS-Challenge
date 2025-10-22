# Estructura Modular de Terraform

Esta estructura modular permite gestionar múltiples entornos de forma limpia y reutilizable.

## 📁 Estructura de Carpetas

```
terraform/
├── modules/
│   └── app_environment/      # Módulo reutilizable
│       ├── main.tf           # Recursos (AKS, ACR, Key Vault, etc.)
│       ├── variables.tf      # Variables de entrada
│       └── outputs.tf        # Salidas del módulo
│
└── environments/
    ├── test/                 # Entorno de TEST
    │   ├── main.tf           # Llama al módulo app_environment
    │   ├── variables.tf      # Variables del entorno
    │   └── test.tfvars       # Valores para TEST (1 nodo, recursos mínimos)
    │
    └── prod/                 # Entorno de PRODUCCIÓN
        ├── main.tf           # Llama al módulo app_environment
        ├── variables.tf      # Variables del entorno
        └── prod.tfvars       # Valores para PROD (1 nodo, recursos optimizados)
```

## 🚀 Cómo usar

### Desplegar entorno de TEST
```bash
cd environments/test
terraform init
terraform plan -var-file=test.tfvars
terraform apply -var-file=test.tfvars
```

### Desplegar entorno de PRODUCCIÓN
```bash
cd environments/prod
terraform init
terraform plan -var-file=prod.tfvars
terraform apply -var-file=prod.tfvars
```

### Ver outputs
```bash
# Desde cualquier entorno
terraform output
```

## 📊 Configuración por Entorno

| Entorno | Nodos | vCPUs | Uso | ACR |
|---------|-------|-------|-----|-----|
| **test** | 1 | 2 | Testing | `devopstestacr` |
| **prod** | 1 | 2 | Producción | `devopsprodacr` |

## 🔧 Ventajas de esta estructura

1. **Reutilizable**: Un solo módulo para todos los entornos
2. **Mantenible**: Cambios en un lugar se aplican a todos
3. **Escalable**: Fácil agregar nuevos entornos
4. **Limpio**: Separación clara entre entornos
5. **Versionado**: Cada entorno puede tener su propia versión

## 📝 Próximos pasos

1. **Migrar configuración existente** a esta nueva estructura
2. **Configurar CI/CD** para usar los nuevos entornos
3. **Agregar más entornos** si es necesario (dev, staging, etc.)
