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