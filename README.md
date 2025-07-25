# Colombia FEV RIPS – Espejo de Registro Docker y Validador

[![CI Status](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/workflows/retag-image.yml/badge.svg)](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions)
[![Container Image](https://img.shields.io/badge/ghcr.io-pahventure%2Fcolombia--fev--rips--docker--validator-blue?logo=docker)](https://github.com/orgs/PahVenture/packages?tab=packages)
[![License](https://img.shields.io/github/license/PahVenture/colombia-fev-rips-docker-validator)](LICENSE)

**Espejo de Registro Docker** para la API y base de datos **FEV RIPS** utilizada para validar y procesar registros del *Registro Individual de Prestación de Servicios de Salud* (RIPS) en Colombia.  
Este proyecto crea un espejo sincronizado de las imágenes originales del Azure Container Registry (ACR), retagueando y distribuyéndolas a través del GitHub Container Registry (GHCR) para mejorar la disponibilidad y propósitos de notificación.

> 🔐 **Alerta de Seguridad**: La contraseña por defecto `P4hv3ntur3!R3c0m31nd4#C4mb14r3st4Cl4v3@` se proporciona solo para propósitos de desarrollo. **Por favor cambie esta contraseña inmediatamente** en entornos de producción.

---

## Propósito

Este repositorio sirve como un **espejo de registro Docker habilitado para notificaciones** para el sistema de validación Colombia FEV RIPS. Automáticamente extrae imágenes del Azure Container Registry oficial, aplica etiquetas estandarizadas, y las redistribuye a través del GitHub Container Registry para asegurar:

- **Disponibilidad mejorada** - Múltiples fuentes de registro para servicios críticos de validación de salud
- **Capacidades de notificación** - Notificaciones nativas de GitHub para actualizaciones de imágenes
- **Etiquetado estandarizado** - Gestión consistente de versiones a través de entornos
- **Control de acceso** - Aprovechando el sistema de permisos de GitHub para acceso de equipo

---

## Características

* **Espejo de Registro** - Sincronización automatizada de ACR a GHCR
* **Imágenes listas para producción** – construidas y escaneadas por GitHub Actions, distribuidas vía GHCR
* **Valores por defecto seguros** – los secretos se pasan a través de Docker secrets / variables de entorno; no se almacenan credenciales en las imágenes
* **Flujo de trabajo de reetiquetado automatizado** – cada imagen ACR se extrae, se re-etiqueta con `latest`, fecha de construcción (`YYYYMMDD`) y número de ejecución, luego se envía a GHCR
* **Integración de notificaciones** - Notificaciones de GitHub para nueva disponibilidad de imágenes
* **Verificaciones de salud** - Monitoreo de salud incorporado para todos los servicios
* **Soporte multi-entorno** - Entornos de producción y staging separados
* **Límites de recursos** – límites de CPU / memoria de contenedor configurados para operación predecible
* **Despliegue declarativo** – un solo archivo `docker compose` para activar API + SQL Server localmente o en la nube

---

## Estructura del Proyecto

```
├── fevrips-docker-compose.yml             # Configuración completa multi-entorno
├── .github/workflows/
│   └── retag-image.yml                    # CI: reetiquetado + push a GHCR (espejo de registro)
└── README.md
```

---

## 🏗️ Configuración de Docker Compose

El archivo `fevrips-docker-compose.yml` proporciona una configuración completa multi-entorno:

### Resumen de Servicios
| Servicio | Puerto | Propósito | Verificación de Salud |
|---------|------|---------|--------------|
| **fevrips-db** | 1433 | Base de datos SQL Server 2022 | Prueba de conectividad SQL |
| **fevrips-api-prod** | 5100 | Servicio API de producción | Prueba de endpoint HTTP |
| **fevrips-api-stage** | 5200 | Servicio API de staging | Prueba de endpoint HTTP |

### Despliegue Local Rápido
```bash
# Clonar e iniciar todos los servicios
git clone https://github.com/PahVenture/colombia-fev-rips-docker-validator.git
cd colombia-fev-rips-docker-validator
docker-compose -f fevrips-docker-compose.yml up -d

# Verificar que los servicios estén saludables
docker-compose -f fevrips-docker-compose.yml ps
```

---

## Integración Continua

| Flujo de Trabajo | Propósito | Registro Fuente | Registro Destino |
|----------|---------|-----------------|-----------------|
| **retag-image.yml** | Activación manual – extrae imagen de ACR, reetiqueta (`latest`, fecha, # ejecución), envía a GHCR | `crmspsgovcoprd.azurecr.io/production-fevrips-apilocal` | `ghcr.io/pahventure/colombia-fev-rips-docker-validator` |

### Detalles del Flujo de Trabajo
- **Activador**: Activación manual de flujo de trabajo
- **Fuente**: Azure Container Registry (ACR)
- **Destino**: GitHub Container Registry (GHCR)
- **Etiquetas Aplicadas**: `latest`, `YYYYMMDD`, `<número-ejecución>`
- **Seguridad**: Usa referenciación basada en digest para inmutabilidad

Ejemplo de ejecución: [GitHub Actions #16235526076](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/runs/16235526076)

---

## Configuración

### Variables de Entorno
| Variable | Ubicación | Descripción | Ejemplo |
|----------|----------|-------------|---------|
| `ACR_USERNAME` / `ACR_PASSWORD` | **GitHub Secrets** | Credenciales para acceso al Azure Container Registry | - |
| `MSSQL_SA_PASSWORD` | **Docker Compose** | Contraseña de administrador de SQL Server | ⚠️ **Cambiar del valor por defecto** |
| `ASPNETCORE_ENVIRONMENT` | **Docker Compose** | Entorno ASP.NET Core | `DockerProduction` |
| `ASPNETCORE_URLS` | **Docker Compose** | URL de enlace de la API | `http://+:5100` |

### Configuración de Seguridad
> 🔒 **Notas Importantes de Seguridad**:
> - **Cambie la contraseña por defecto** `P4hv3ntur3!R3c0m31nd4#C4mb14r3st4Cl4v3@` inmediatamente
> - Use Docker secrets para despliegues de producción
> - Habilite certificados TLS para entornos de producción
> - Configure reglas de firewall apropiadas

---

## Usando el Espejo de Registro

### Extrayendo Imágenes
```bash
# Versión estable más reciente
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest

# Versión de fecha específica
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:20241207

# Versión de construcción específica
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:42
```

### Ejecutando Servicios Individuales
```bash
# Solo base de datos
docker run -d --name fevrips-db \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=TuContraseñaSegura123! \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-CU12-ubuntu-22.04

# Servicio API (conecta a base de datos externa)
docker run -d --name fevrips-api \
  -e ASPNETCORE_ENVIRONMENT=DockerProduction \
  -e ConnectionStrings__DefaultConnection="Server=tu-servidor-bd;Database=FEVRIPS;User Id=sa;Password=TuContraseñaSegura123!;TrustServerCertificate=True;" \
  -p 8080:5100 \
  ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest
```

---

## Actualizando Imágenes

Para publicar una nueva versión de ACR a GHCR:

1. Navega a **Actions > Retag & Push Image**
2. Haz clic en **Run workflow**, proporciona una etiqueta o un digest (ej. `sha256:…`)
3. El flujo de trabajo reetiquetará y enviará:
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest`
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:YYYYMMDD`
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:<número-ejecución>`

---

## Documentación de la API

### Endpoints
- **POST /api/rips/validate** - Validar archivo RIPS
- **GET /health** - Endpoint de verificación de salud
- **GET /api/version** - Información de versión de la API

### Ejemplo de Uso
```bash
# Verificación de salud
curl http://localhost:5100/health

# Validar archivo RIPS
curl -X POST http://localhost:5100/api/rips/validate \
  -H "Content-Type: application/json" \
  -d @datos-rips.json
```

---

## Mejores Prácticas Seguidas

* **Espejo de registro** - Asegura alta disponibilidad y redundancia para servicios críticos de salud
* **Principio de menor privilegio** – el trabajo de GH Actions solicita solo `contents` de solo lectura y `write` en `packages`
* **Las imágenes se referencian por digest** durante el reetiquetado para garantizar inmutabilidad
* **Todas las rutas de repositorio enviadas a GHCR** se fuerzan a `minúsculas` para satisfacer la especificación OCI
* **Límites de memoria de SQL Server** aplicados para prevenir agotamiento del host
* **Los secretos nunca se almacenan** en el repositorio
* **Verificaciones de salud** - Todos los servicios incluyen monitoreo integral de salud
* **Entornos multi-etapa** - Despliegues de producción y staging separados

---

## Acerca de PahVenture

Este proyecto es mantenido por **PahVenture**, una empresa visionaria de desarrollo de software y capital de riesgo especializada en desarrollo impulsado por IA, soluciones de software personalizadas e inversiones tecnológicas estratégicas.

- **Sitio web**: [https://pahventure.com](https://pahventure.com)
- **Email**: [dev@pahventure.com](mailto:dev@pahventure.com)
- **GitHub**: [@PahVenture](https://github.com/PahVenture)
- **API Hospedada**: [https://fevrips.pahventure.com/services](https://fevrips.pahventure.com/services)

---

## Contribuyendo

¡Los pull-requests son bienvenidos! Por favor:

1. Haz fork del repositorio y crea una rama de característica
2. Sigue el estilo de código existente y las convenciones de espejo de registro
3. Prueba el flujo de trabajo de espejo de registro localmente
4. Abre un PR contra `main` con una descripción clara

---

## Licencia

Este proyecto está licenciado bajo la **Licencia MIT** – consulta [LICENSE](LICENSE) para detalles.

---

## Reconocimientos

* **Ministerio de Salud de Colombia** - Por las pautas FEV RIPS y lógica de validación
* **Microsoft** - Contenedor SQL Server y Azure Container Registry
* **GitHub** - Actions y GHCR para CI/CD y hosting de registro
* **PahVenture** - Por mantener este espejo de registro, servicio de API hospedado y sistema de notificaciones
