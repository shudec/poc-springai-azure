# Spring AI Azure OpenAI Demo

Enterprise-ready Spring Boot 3.x application demonstrating Azure OpenAI integration with dual authentication (API Key for dev, Managed Identity for production), rate limiting, comprehensive monitoring, and deployment to both Azure App Service and Container Apps.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          GitHub Actions CI/CD                           │
│  ┌──────────────────┐              ┌──────────────────────────────┐   │
│  │ Deploy AppService│              │ Deploy Container Apps        │   │
│  └────────┬─────────┘              └──────────┬───────────────────┘   │
└───────────┼────────────────────────────────────┼─────────────────────┘
            │                                    │
            ▼                                    ▼
   ┌────────────────┐                  ┌─────────────────────┐
   │  App Service   │                  │  Container Apps     │
   │   (P1v2)       │                  │  Environment        │
   │  Java 21       │                  │  + ACR              │
   └────┬───────────┘                  └─────────┬───────────┘
        │                                        │
        │          ┌─────────────────────────────┘
        │          │
        ▼          ▼
   ┌────────────────────────────────────────────┐
   │     User-Assigned Managed Identity         │
   │  (RBAC: Cognitive Services OpenAI User)    │
   └────────────────┬───────────────────────────┘
                    │
        ┌───────────┴───────────┬──────────────────┐
        ▼                       ▼                  ▼
┌───────────────┐      ┌─────────────────┐  ┌──────────────┐
│ Azure OpenAI  │      │ App Insights    │  │  Log Analytics│
│ (gpt-4o-mini) │      │ (Monitoring)    │  │  Workspace    │
└───────────────┘      └─────────────────┘  └──────────────┘
```

## Features

- ✅ **Spring AI Integration**: Leverages Spring AI framework for Azure OpenAI
- ✅ **Dual Authentication**: API Key (dev) + Managed Identity (prod)
- ✅ **Rate Limiting**: Bucket4j-based request throttling (10 req/min default)
- ✅ **Monitoring**: Application Insights integration with custom telemetry
- ✅ **Dual Deployment**: App Service + Container Apps options
- ✅ **Infrastructure as Code**: Complete Terraform modules with RBAC
- ✅ **CI/CD**: GitHub Actions workflows for automated deployment
- ✅ **Comprehensive Tests**: Unit + Integration tests with Mockito

## Prerequisites

- Java 21 (Eclipse Temurin recommended)
- Maven 3.8+
- Terraform 1.5+
- Azure CLI 2.50+
- Azure Subscription with permissions to create resources
- GitHub account (for CI/CD)

## Quick Start

### 1. Infrastructure Deployment

```bash
# Login to Azure
az login

# Navigate to Terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var="environment=dev"

# Deploy infrastructure (Container Apps only to avoid App Service policy)
terraform apply -var="environment=dev" -var="deployment_type=containerapp" -auto-approve

# Note: For Sopra Steria DEP policy compliance, you may need to add additional tags:
# terraform apply -var="environment=dev" -var="cost_center=YOUR_COST_CENTER" -var="owner=your.email@example.com"

# Extract outputs for GitHub Secrets
terraform output -json github_secrets > secrets.json
```

### 2. Configure GitHub Secrets

Create the following GitHub repository secrets from Terraform outputs:

```bash
# Script to set GitHub secrets (requires GitHub CLI)
#!/bin/bash

REPO_OWNER="shudec"
REPO_NAME="poc-springai-azure"

# Extract values from Terraform output
SECRETS=$(terraform output -json github_secrets)

gh secret set AZURE_CREDENTIALS -b "$AZURE_CREDENTIALS" -r $REPO_OWNER/$REPO_NAME
gh secret set ACR_LOGIN_SERVER -b "$(echo $SECRETS | jq -r '.ACR_LOGIN_SERVER')" -r $REPO_OWNER/$REPO_NAME
gh secret set ACR_USERNAME -b "$(echo $SECRETS | jq -r '.ACR_USERNAME')" -r $REPO_OWNER/$REPO_NAME
gh secret set ACR_PASSWORD -b "$(echo $SECRETS | jq -r '.ACR_PASSWORD')" -r $REPO_OWNER/$REPO_NAME
gh secret set APP_SERVICE_NAME -b "$(echo $SECRETS | jq -r '.APP_SERVICE_NAME')" -r $REPO_OWNER/$REPO_NAME
gh secret set CONTAINER_APP_NAME -b "$(echo $SECRETS | jq -r '.CONTAINER_APP_NAME')" -r $REPO_OWNER/$REPO_NAME
gh secret set RESOURCE_GROUP_NAME -b "$(echo $SECRETS | jq -r '.RESOURCE_GROUP_NAME')" -r $REPO_OWNER/$REPO_NAME
```

Required GitHub Secrets:
- `AZURE_CREDENTIALS`: Service principal credentials (JSON)
- `ACR_LOGIN_SERVER`: Container Registry URL
- `ACR_USERNAME`: ACR admin username
- `ACR_PASSWORD`: ACR admin password
- `APP_SERVICE_NAME`: App Service name
- `CONTAINER_APP_NAME`: Container App name
- `RESOURCE_GROUP_NAME`: Azure Resource Group name

### 3. Local Development

```bash
# Set environment variables for dev profile
export AZURE_OPENAI_ENDPOINT="https://openai-dev.openai.azure.com/"
export AZURE_OPENAI_API_KEY="your-api-key-here"
export AZURE_OPENAI_DEPLOYMENT_NAME="gpt-4o-mini"
export SPRING_PROFILES_ACTIVE="dev"

# Run tests
mvn test

# Run the application
mvn spring-boot:run

# Or with Maven Wrapper
./mvnw spring-boot:run
```

### 4. Test the API

```bash
# Health check
curl http://localhost:8080/api/chat/health

# Chat endpoint
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is Spring AI?"}'

# Expected response:
{
  "response": "Spring AI is a framework...",
  "timestamp": "2026-02-05T10:30:00Z",
  "model": "gpt-4o-mini"
}

# Test rate limiting (send 11 requests quickly)
for i in {1..11}; do
  curl -X POST http://localhost:8080/api/chat \
    -H "Content-Type: application/json" \
    -d "{\"message\": \"Test $i\"}"
  echo ""
done
# 11th request should return 429 Too Many Requests
```

## Project Structure

```
poc-azure/
├── src/
│   ├── main/
│   │   ├── java/com/ssg/ccoe/demo/azure/springai/
│   │   │   ├── SpringAiApplication.java
│   │   │   ├── controller/
│   │   │   │   └── ChatController.java        # REST API with rate limiting
│   │   │   ├── service/
│   │   │   │   └── ChatService.java           # AI logic
│   │   │   ├── config/
│   │   │   │   ├── AzureOpenAiConfig.java     # Dual auth config
│   │   │   │   └── RateLimitConfig.java       # Bucket4j setup
│   │   │   ├── model/dto/
│   │   │   │   ├── ChatRequest.java
│   │   │   │   └── ChatResponse.java
│   │   │   └── exception/
│   │   │       └── GlobalExceptionHandler.java
│   │   └── resources/
│   │       ├── application.yml                # Base config
│   │       ├── application-dev.yml            # Dev profile (API Key)
│   │       └── application-prod.yml           # Prod profile (Managed Identity)
│   └── test/
│       └── java/com/ssg/ccoe/demo/azure/springai/
│           ├── service/ChatServiceTest.java
│           ├── controller/ChatControllerIntegrationTest.java
│           └── RateLimitIntegrationTest.java
├── terraform/
│   ├── modules/
│   │   ├── openai/                            # Azure OpenAI + RBAC
│   │   ├── shared/                            # ACR, App Insights, Identity
│   │   ├── app-service/                       # App Service deployment
│   │   └── container-apps/                    # Container Apps deployment
│   ├── main.tf                                # Root module
│   ├── variables.tf                           # Input variables
│   ├── outputs.tf                             # Outputs + GitHub secrets map
│   └── backend.tf                             # Local state (demo)
├── .github/
│   └── workflows/
│       ├── deploy-appservice.yml              # App Service CI/CD
│       ├── deploy-containerapp.yml            # Container Apps CI/CD
│       └── ci-tests.yml                       # PR validation
├── Dockerfile                                 # Multi-stage build
├── pom.xml                                    # Maven dependencies
└── README.md
```

## Configuration

### Application Properties

| Property | Description | Default |
|----------|-------------|---------|
| `spring.ai.azure.openai.endpoint` | Azure OpenAI endpoint | (required) |
| `spring.ai.azure.openai.api-key` | API Key (dev only) | - |
| `spring.ai.azure.openai.chat.options.deployment-name` | Model deployment | gpt-4o-mini |
| `rate.limit.requests-per-minute` | Rate limit threshold | 10 |
| `azure.application-insights.connection-string` | App Insights | - |

### Terraform Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `location` | Azure region | westeurope |
| `environment` | Environment (dev/prod) | dev |
| `rate_limit_rpm` | Rate limit requests/min | 10 |
| `deployment_type` | appservice/containerapp/both | both |

## Deployment Options

### Option 1: App Service

```bash
# Deploy via GitHub Actions (automatic on push to main)
git push origin main

# Or manual deployment
cd terraform
terraform apply -var="deployment_type=appservice"

# Get App Service URL
terraform output app_service_url
```

### Option 2: Container Apps

```bash
# Build and push image to ACR first
# Get ACR login server from terraform output
ACR_SERVER=$(terraform output -raw acr_login_server)
ACR_NAME=$(echo $ACR_SERVER | cut -d'.' -f1)

# Login to ACR
az acr login --name $ACR_NAME

# Build and push using Maven Jib
mvn compile jib:build -Djib.to.image=$ACR_SERVER/springai-azure-demo:latest

# Update Container App to use the new image (if using placeholder)
cd terraform
terraform apply -var="environment=dev" -var="deployment_type=containerapp"

# Get Container App URL
terraform output container_app_url
```

**Note**: The initial deployment uses a placeholder Microsoft image. After building your application image, you need to update the container app configuration or redeploy.

### Option 3: Both

```bash
# Default deployment includes both
terraform apply -var="deployment_type=both"
```

## Monitoring with Application Insights

### Key Queries

```kusto
// Request rate analysis
requests
| where timestamp > ago(1h)
| summarize count() by bin(timestamp, 5m)
| render timechart

// Rate limit violations
traces
| where message contains "Rate limit exceeded"
| summarize count() by bin(timestamp, 5m)

// AI service errors
exceptions
| where outerMessage contains "OpenAI"
| project timestamp, outerMessage, problemId
| order by timestamp desc

// Performance metrics
requests
| where name == "POST /api/chat"
| summarize avg(duration), percentile(duration, 95) by bin(timestamp, 5m)
```

### Custom Metrics

The application automatically tracks:
- Request count per endpoint
- Response times (avg, p95, p99)
- Rate limit hit count
- Azure OpenAI API errors
- Token usage (if enabled)

## Security Considerations

### Authentication Flow

**Development (API Key)**:
```
Client → App Service → Azure OpenAI
                 ↓
            API Key Header
```

**Production (Managed Identity)**:
```
Client → App Service → Managed Identity → Azure AD Token → Azure OpenAI
                 ↓
            No API Key Needed
```

### RBAC Roles

Terraform automatically assigns:
- **Cognitive Services OpenAI User**: Managed Identity → Azure OpenAI
- **AcrPull**: Managed Identity → ACR
- **Monitoring Metrics Publisher**: Managed Identity → App Insights

### Network Security

Current setup:
- ✅ Public endpoints (demo purposes)
- ⚠️ No VNet integration
- ⚠️ No Private Endpoints

Production recommendations:
- Enable VNet integration for App Service/Container Apps
- Use Private Endpoints for Azure OpenAI
- Configure NSG rules
- Enable Azure Front Door with WAF

## Troubleshooting

### Issue: DEP Policy "RequestDisallowedByPolicy" for App Service

If deploying to Sopra Steria Azure subscriptions, App Service Plans may be blocked by DEP policies.

**Solution 1**: Deploy Container Apps instead (recommended for demo)
```bash
terraform apply -var="environment=dev" -var="deployment_type=containerapp"
```

**Solution 2**: Add required DEP compliance tags
```bash
terraform apply -var="environment=dev" \
  -var="cost_center=YOUR_COST_CENTER" \
  -var="owner=your.email@soprasteria.com"
```

Check your organization's DEP documentation for required tag values: https://docs.dep.soprasteria.com/docs/platforms/azure/restriction-policies/

### Issue: Container App "MANIFEST_UNKNOWN: manifest tagged by 'latest' is not found"

The container image doesn't exist in ACR yet.

**Solution**: Build and push the image first
```bash
# Get ACR details
ACR_SERVER=$(cd terraform && terraform output -raw acr_login_server)
ACR_NAME=$(echo $ACR_SERVER | cut -d'.' -f1)

# Login and build
az acr login --name $ACR_NAME
mvn compile jib:build -Djib.to.image=$ACR_SERVER/springai-azure-demo:latest

# Update the container app image reference
cd terraform/modules/container-apps
# Edit main.tf line 31 to use your ACR image instead of placeholder
# image = "${var.acr_login_server}/springai-azure-demo:latest"
```

### Issue: "Authentication failed" in production

```bash
# Verify managed identity has correct role
az role assignment list \
  --assignee $(az identity show -n id-dev-springai -g rg-dev-springai --query principalId -o tsv) \
  --scope /subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.CognitiveServices/accounts/{openai-name}
```

### Issue: Rate limit not working

```bash
# Check Bucket4j bean creation
curl http://localhost:8080/actuator/beans | jq '.contexts.application.beans | keys[] | select(. | contains("bucket"))'

# Verify configuration
curl http://localhost:8080/actuator/env | jq '.propertySources[] | select(.name | contains("application"))'
```

### Issue: Container App won't start

```bash
# Check container logs
az containerapp logs show \
  --name ca-dev-springai \
  --resource-group rg-dev-springai \
  --follow

# Verify image in ACR
az acr repository show-tags \
  --name acrdevspringai123456 \
  --repository springai-azure-demo
```

## Cost Optimization

Estimated monthly costs (West Europe):

| Service | SKU/Tier | Cost |
|---------|----------|------|
| Azure OpenAI | S0 (10K TPM) | ~$10 |
| App Service | P1v2 | ~$75 |
| Container Apps | 0.5 vCPU, 1GB | ~$15 |
| ACR | Basic | ~$5 |
| Log Analytics | 5GB ingestion | ~$10 |
| **Total** | | **~$115/month** |

**Cost-saving tips**:
- Use Free tier App Service for dev ($0)
- Reduce OpenAI capacity to 1K TPM for testing
- Enable App Insights sampling (20%)
- Use consumption-based Container Apps pricing

## Further Considerations

### 1. Rate Limiting Scope

**Current**: Global in-memory rate limit (10 req/min across all users)

**Options**:
- Per-IP rate limiting → Requires Redis/distributed cache
- Per-user rate limiting → Requires authentication
- Per-tenant rate limiting → Requires multi-tenancy support

### 2. Application Insights Sampling

**Current**: 100% sampling (all requests tracked)

**Recommendation for production**:
```yaml
azure:
  application-insights:
    sampling-percentage: 20  # Reduce to 20% for cost savings
```

### 3. Multi-Environment Strategy

**Current**: Single environment via Terraform variables

**Options**:
- Separate Azure subscriptions (dev/staging/prod)
- Terraform workspaces (not compatible with local backend)
- Resource naming suffixes (`-dev`, `-prod`)

### 4. CI/CD Trigger Strategy

**Current**: Deploy on push to `main`

**Options**:
- Add `ci-tests.yml` for PR validation
- Manual approval gates for production
- Blue-green deployments
- Canary releases with traffic splitting (Container Apps)

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues or questions:
- Open a GitHub issue
- Contact: your-team@example.com

---

**Built with**: Spring Boot 3.2.2, Spring AI 1.0.0-M4, Java 21, Azure OpenAI (gpt-4o-mini)
