# Colombia FEV RIPS – Docker Validator

[![CI Status](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/workflows/retag-image.yml/badge.svg)](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions)
[![Container Image](https://img.shields.io/badge/ghcr.io-pahventure%2Fcolombia--fev--rips--docker--validator-blue?logo=docker)](https://github.com/orgs/PahVenture/packages?tab=packages)
[![License](https://img.shields.io/github/license/PahVenture/colombia-fev-rips-docker-validator)](LICENSE)

Docker-based distribution of the **FEV RIPS** API & database used to validate and process *Registro Individual de Prestación de Servicios de Salud* (RIPS) records in Colombia.  
The project packages the API (*ASP.NET Core*) and SQL Server database into a production-ready, self-contained stack that can be pulled and started with a single command.

---

## Features

* **Production-ready images** – built and scanned by GitHub Actions, distributed via GHCR.  
* **Secure defaults** – secrets are passed through Docker secrets / environment variables; no credentials stored in images.  
* **Automated retag workflow** – every ACR image is pulled, re-tagged with `latest`, build date (`YYYYMMDD`) and run number, then pushed to GHCR.  
* **Resource limits** – container CPU / memory limits configured for predictable operation.  
* **Declarative deployment** – single `docker compose` file to spin up API + SQL Server locally or in the cloud.

---

## Project Structure

```
├── apilocal-dockercompose.Production.yml  # Compose file (API + SQL Server)
├── .github/workflows/
│   └── retag-image.yml                    # CI: retag + push to GHCR
└── README.md
```

---

## Continuous Integration

| Workflow | Purpose |
|----------|---------|
| **retag-image.yml** | Manually triggered – pulls image from ACR, retags (`latest`, date, run #), pushes to GHCR. |

Example run: [GitHub Actions #16235526076](https://github.com/PahVenture/colombia-fev-rips-docker-validator/actions/runs/16235526076)

---

## Configuration

| Variable | Location | Description |
|----------|----------|-------------|
| `ACR_USERNAME` / `ACR_PASSWORD` | **GitHub Secrets** &rarr; used by workflow to pull from ACR. |
| `MSSQL_SA_PASSWORD` | `apilocal-dockercompose.Production.yml` | SQL Server `sa` password. Change for anything other than local testing. |
| `ASPNETCORE_Kestrel__Certificates__*` | Compose env vars | TLS certificate path / password for the API. |

---

## Updating Images

To publish a new version from ACR to GHCR:

1. Browse to **Actions > Retag & Push Image**.  
2. Click **Run workflow**, supply a tag or a digest (e.g. `sha256:…`).  
3. The workflow will retag and push:  
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:latest`  
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:YYYYMMDD`  
   * `ghcr.io/pahventure/colombia-fev-rips-docker-validator:<run-number>`  

---

## Best Practices Followed

* Principle of least privilege – GH Actions job requests read-only `contents` and `write` on `packages` only.  
* Images are referenced by **digest** during retagging to guarantee immutability.  
* All repository paths pushed to GHCR are forced `lowercase` to satisfy OCI spec.  
* SQL Server memory limits applied to prevent host exhaustion.  
* Secrets never stored in the repository.

---

## Contributing

Pull-requests are welcome! Please:

1. Fork the repo & create a feature branch.  
2. Follow existing code style / compose conventions.  
3. Run `docker compose -f apilocal-dockercompose.Production.yml up --build` locally.  
4. Open a PR against `main` with a clear description.

---

## License

This project is licensed under the **MIT License** – see [LICENSE](LICENSE) for details.

---

## Acknowledgements

* Microsoft SQL Server container courtesy of Microsoft.  
* GitHub Actions & GHCR for CI/CD.  
* Colombian FEV RIPS guidelines for validation logic.
