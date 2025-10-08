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

### Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Terraform installed
- Node.js and npm (for function deployment)

### Setup Remote Backend

First, create the Azure Storage backend for Terraform state:

```bash
make backend-create                                    # Create backend with defaults
# Or customize:
make backend-create RESOURCE_GROUP=my-tfstate LOCATION=eastus
```

This creates a storage account, container, and generates `.terraform-backend.env` with configuration.

### Setup Terraform

```bash
make tf-init       # Initialize Terraform with remote backend
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
