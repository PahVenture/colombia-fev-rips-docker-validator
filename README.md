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
