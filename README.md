# Colombia FEV RIPS – Docker Registry Mirror & Validator

[![CI Status](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/workflows/retag-image.yml/badge.svg)](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions)
[![Container Image](https://img.shields.io/badge/ghcr.io-pahventure%2Fcolombia--fev--rips--docker--validator-blue?logo=docker)](https://github.com/orgs/PahVenture/packages?tab=packages)
[![License](https://img.shields.io/github/license/PahVenture/colombia-fev-rips-docker-validator)](LICENSE)

**Docker Registry Mirror** for the **FEV RIPS** API & database used to validate and process *Registro Individual de Prestación de Servicios de Salud* (RIPS) records in Colombia.  
This project creates a synchronized mirror of the original Azure Container Registry (ACR) images, retagging and distributing them via GitHub Container Registry (GHCR) for enhanced availability and notification purposes.

> 🔐 **Security Alert**: The default password `P4hv3ntur3!R3c0m31nd4#C4mb14r3st4Cl4v3@` is provided for development purposes only. **Please change this password immediately** in production environments.

---

## Purpose

This repository serves as a **notification-enabled Docker registry mirror** for the Colombia FEV RIPS validation system. It automatically pulls images from the official Azure Container Registry, applies standardized tags, and redistributes them through GitHub Container Registry to ensure:

- **Enhanced availability** - Multiple registry sources for critical healthcare validation services
- **Notification capabilities** - GitHub-native notifications for image updates
- **Standardized tagging** - Consistent version management across environments
- **Access control** - Leveraging GitHub's permission system for team access

---

## Features

* **Registry Mirroring** - Automated synchronization from ACR to GHCR
* **Production-ready images** – built and scanned by GitHub Actions, distributed via GHCR
* **Secure defaults** – secrets are passed through Docker secrets / environment variables; no credentials stored in images
* **Automated retag workflow** – every ACR image is pulled, re-tagged with `latest`, build date (`YYYYMMDD`) and run number, then pushed to GHCR
* **Notification integration** - GitHub notifications for new image availability
* **Health checks** - Built-in health monitoring for all services
* **Multi-environment support** - Separate production and staging environments
* **Resource limits** – container CPU / memory limits configured for predictable operation
* **Declarative deployment** – single `docker compose` file to spin up API + SQL Server locally or in the cloud

---

## Project Structure

```
├── fevrips-docker-compose.yml             # Complete multi-environment setup
├── helm/fevrips/                          # Helm chart for Kubernetes deployment
│   ├── Chart.yaml                         # Chart metadata
│   ├── values.yaml                        # Default configuration values
│   ├── values-production.yaml             # Production environment values
│   ├── values-development.yaml            # Development environment values
│   └── templates/                         # Kubernetes resource templates
├── .github/workflows/
│   └── retag-image.yml                    # CI: retag + push to GHCR (registry mirror)
└── README.md
```

---

## 🏗️ Docker Compose Configuration

The `fevrips-docker-compose.yml` file provides a complete multi-environment setup:

### Services Overview
| Service | Port | Purpose | Health Check |
|---------|------|---------|--------------|
| **fevrips-db** | 1433 | SQL Server 2022 database | SQL connectivity test |
| **fevrips-api-prod** | 5100 | Production API service | HTTP endpoint test |
| **fevrips-api-stage** | 5200 | Staging API service | HTTP endpoint test |

### Quick Local Deployment
```bash
# Clone and start all services
git clone https://github.com/PahVenture/colombia-fev-rips-docker-validator.git
cd colombia-fev-rips-docker-validator
docker-compose -f fevrips-docker-compose.yml up -d

# Verify services are healthy
docker-compose -f fevrips-docker-compose.yml ps
```

---

## ⎈ Helm Kubernetes Deployment

The project includes a comprehensive Helm chart for Kubernetes deployment, providing the same functionality as Docker Compose with additional Kubernetes-native features.

### Kubernetes Services Overview
| Component | Type | Purpose | Features |
|-----------|------|---------|----------|
| **Database** | StatefulSet | SQL Server with persistent storage | Health checks, resource limits, persistence |
| **Production API** | Deployment | Production API service | Auto-scaling, rolling updates, health checks |
| **Staging API** | Deployment | Staging API service | Configurable replicas, resource limits |
| **Services** | ClusterIP/NodePort | Internal communication | Load balancing, service discovery |
| **Ingress** | Optional | External access | TLS termination, path-based routing |

### Quick Kubernetes Deployment

#### Prerequisites
```bash
# Ensure you have Helm 3.x installed
helm version

# Ensure kubectl is configured for your cluster
kubectl cluster-info
```

#### Development Deployment
```bash
# Clone the repository
git clone https://github.com/PahVenture/colombia-fev-rips-docker-validator.git
cd colombia-fev-rips-docker-validator

# Deploy with development settings
helm install fevrips-dev helm/fevrips -f helm/fevrips/values-development.yaml

# Check deployment status
kubectl get pods
kubectl get services

# Access the application (development uses NodePort)
kubectl get svc fevrips-dev-api-prod -o jsonpath='{.spec.ports[0].nodePort}'
# Visit http://<node-ip>:<node-port>
```

#### Production Deployment
```bash
# Create namespace for production
kubectl create namespace fevrips-prod

# Create secret for database credentials (recommended for production)
kubectl create secret generic fevrips-db-credentials \
  --from-literal=sa-password='YourSecureProductionPassword!' \
  -n fevrips-prod

# Deploy with production settings
helm install fevrips-prod helm/fevrips \
  -f helm/fevrips/values-production.yaml \
  -n fevrips-prod \
  --set database.auth.existingSecret=fevrips-db-credentials

# Enable autoscaling
kubectl autoscale deployment fevrips-prod-api-prod \
  --cpu-percent=70 \
  --min=2 \
  --max=10 \
  -n fevrips-prod
```

### Helm Configuration Options

#### Database Configuration
```yaml
database:
  persistence:
    enabled: true          # Enable persistent storage
    storageClass: "fast"   # Storage class name
    size: 20Gi            # Storage size
  
  resources:
    limits:
      cpu: 2000m
      memory: 4Gi
  
  auth:
    existingSecret: ""     # Use existing secret for credentials
    rootPassword: ""       # Database password (if not using existing secret)
```

#### API Configuration
```yaml
api:
  production:
    enabled: true
    replicaCount: 3
    resources:
      limits:
        cpu: 1000m
        memory: 1Gi
  
  staging:
    enabled: true          # Enable/disable staging environment
    replicaCount: 1
```

#### Ingress Configuration
```yaml
ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: fevrips.company.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: fevrips-tls
      hosts:
        - fevrips.company.com
```

### Helm Commands Reference

```bash
# Install or upgrade
helm upgrade --install fevrips helm/fevrips

# Uninstall
helm uninstall fevrips

# View generated templates
helm template fevrips helm/fevrips

# Validate chart
helm lint helm/fevrips

# Get deployment status
helm status fevrips

# View configuration values
helm get values fevrips

# Rollback to previous version
helm rollback fevrips 1
```

### Monitoring and Troubleshooting

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=fevrips

# View logs
kubectl logs -f deployment/fevrips-api-prod
kubectl logs -f statefulset/fevrips-db

# Check services
kubectl get svc -l app.kubernetes.io/name=fevrips

# Port forward for local access
kubectl port-forward svc/fevrips-api-prod 8080:5100

# Check ingress
kubectl get ingress fevrips

# View events
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Automated Deployment Script

For simplified deployment, use the included deployment script:

```bash
# Development deployment
./helm/deploy.sh development

# Production deployment
DB_PASSWORD="YourSecurePassword123!" ./helm/deploy.sh production fevrips-prod

# Custom deployment with specific release name
./helm/deploy.sh development my-fevrips-test
```

The script automatically:
- Creates the namespace
- Handles database credentials for production
- Applies the appropriate values file
- Provides post-deployment instructions

---

## Continuous Integration

| Workflow | Purpose | Source Registry | Target Registry |
|----------|---------|-----------------|-----------------|
| **retag-image.yml** | Manually triggered – pulls image from ACR, retags (`latest`, date, run #), pushes to GHCR | `crmspsgovcoprd.azurecr.io/production-fevrips-apilocal` | `ghcr.io/pahventure/colombia-fev-rips-docker-validator` |

### Workflow Details
- **Trigger**: Manual workflow dispatch
- **Source**: Azure Container Registry (ACR)
- **Target**: GitHub Container Registry (GHCR)
- **Tags Applied**: `latest`, `YYYYMMDD`, `<run-number>`
- **Security**: Uses digest-based referencing for immutability

Example run: [GitHub Actions #16235526076](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/runs/16235526076)

---

## Configuration

### Environment Variables
| Variable | Location | Description | Example |
|----------|----------|-------------|---------|
| `ACR_USERNAME` / `ACR_PASSWORD` | **GitHub Secrets** | Credentials for Azure Container Registry access | - |
| `MSSQL_SA_PASSWORD` | **Docker Compose** | SQL Server administrator password | ⚠️ **Change from default** |
| `ASPNETCORE_ENVIRONMENT` | **Docker Compose** | ASP.NET Core environment | `DockerProduction` |
| `ASPNETCORE_URLS` | **Docker Compose** | API binding URL | `http://+:5100` |

### Security Configuration
> 🔒 **Important Security Notes**:
> - **Change the default password** `P4hv3ntur3!R3c0m31nd4#C4mb14r3st4Cl4v3@` immediately
> - Use Docker secrets for production deployments
> - Enable TLS certificates for production environments
> - Configure proper firewall rules

---

## Using the Registry Mirror

### Pulling Images
```bash
# Latest stable version
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest

# Specific date version
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:20241207

# Specific build version
docker pull ghcr.io/pahventure/colombia-fev-rips-docker-validator:42
```

### Running Individual Services
```bash
# Database only
docker run -d --name fevrips-db \
  -e ACCEPT_EULA=Y \
  -e MSSQL_SA_PASSWORD=YourSecurePassword123! \
  -p 1433:1433 \
  mcr.microsoft.com/mssql/server:2022-CU12-ubuntu-22.04

# API service (connects to external database)
docker run -d --name fevrips-api \
  -e ASPNETCORE_ENVIRONMENT=DockerProduction \
  -e ConnectionStrings__DefaultConnection="Server=your-db-server;Database=FEVRIPS;User Id=sa;Password=YourSecurePassword123!;TrustServerCertificate=True;" \
  -p 8080:5100 \
  ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest
```

---

## Updating Images

To publish a new version from ACR to GHCR:

1. Browse to **Actions > Retag & Push Image**
2. Click **Run workflow**, supply a tag or a digest (e.g. `sha256:…`)
3. The workflow will retag and push:
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest`
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:YYYYMMDD`
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:<run-number>`

---

## API Documentation

### Endpoints
- **POST /api/rips/validate** - Validate RIPS file
- **GET /health** - Health check endpoint
- **GET /api/version** - API version information

### Example Usage
```bash
# Health check
curl http://localhost:5100/health

# Validate RIPS file
curl -X POST http://localhost:5100/api/rips/validate \
  -H "Content-Type: application/json" \
  -d @rips-data.json
```

---

## Best Practices Followed

* **Registry mirroring** - Ensures high availability and redundancy for critical healthcare services
* **Principle of least privilege** – GH Actions job requests read-only `contents` and `write` on `packages` only
* **Images are referenced by digest** during retagging to guarantee immutability
* **All repository paths pushed to GHCR** are forced `lowercase` to satisfy OCI spec
* **SQL Server memory limits** applied to prevent host exhaustion
* **Secrets never stored** in the repository
* **Health checks** - All services include comprehensive health monitoring
* **Multi-stage environments** - Separate production and staging deployments

---

## About PahVenture

This project is maintained by **PahVenture**, a forward-thinking software development and venture capital company specializing in AI-driven development, custom software solutions, and strategic technology investments.

- **Website**: [https://pahventure.com](https://pahventure.com)
- **Email**: [dev@pahventure.com](mailto:dev@pahventure.com)
- **GitHub**: [@PahVenture](https://github.com/PahVenture)
- **Hosted API**: [https://fevrips.pahventure.com/services](https://fevrips.pahventure.com/services)

---

## Contributing

Pull-requests are welcome! Please:

1. Fork the repo & create a feature branch
2. Follow existing code style and registry mirroring conventions
3. Test the registry mirroring workflow locally
4. Open a PR against `main` with a clear description

---

## License

This project is licensed under the **MIT License** – see [LICENSE](LICENSE) for details.

---

## Acknowledgements

* **Colombian Ministry of Health** - For FEV RIPS guidelines and validation logic
* **Microsoft** - SQL Server container and Azure Container Registry
* **GitHub** - Actions & GHCR for CI/CD and registry hosting
* **PahVenture** - For maintaining this registry mirror, hosted API service, and notification system
