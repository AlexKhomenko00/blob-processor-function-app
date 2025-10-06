# Azure ETL Demo

A demonstration project showcasing an **Azure serverless ETL pipeline** with Node.js and Terraform.  
Processes blobs in storage containers via Azure Functions with monitoring enabled.

## Features

- Multi-environment Terraform infrastructure (dev, staging/prod optional)
- Azure Function App with Node.js runtime
- Blob containers: `input-raw`, `processed`, `archived`, `failed`
- Managed Identity with RBAC for secure access
- Application Insights + Log Analytics for monitoring
- Blob-triggered ETL functions

## Quick Start

All Terraform and deployment commands are wrapped in the provided `Makefile`.

### Setup Terraform

```bash
make tf-init       # Initialize Terraform
make tf-plan       # Preview changes
make tf-apply      # Apply changes and save outputs
```

### Deploy Azure Functions

```bash
make deploy ENV=dev # Deploy function app to a specific environment
make deploy-all # Deploy to all environments
```

### Test the ETL

Upload a file to the input-raw container in your Azure Storage account — it will be processed automatically by the function app.

### Clean Up

```bash
make tf-destroy # Destroy all Terraform resources
make clean # Remove generated files
```
