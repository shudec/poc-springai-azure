#!/bin/bash
# Script to set GitHub secrets (requires GitHub CLI)

set -e

REPO_OWNER="shudec"
REPO_NAME="poc-springai-azure"

echo "Checking GitHub CLI authentication..."
if ! gh auth status >/dev/null 2>&1; then
    echo "ERROR: GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi

echo "Extracting values from Terraform output..."
SECRETS=$(terraform output -json github_secrets 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to get Terraform outputs. Run 'terraform apply' first."
    exit 1
fi

echo ""
echo "To set secrets, your GitHub token needs 'repo' or 'workflow' scope."
echo "Re-authenticate with proper scopes:"
echo "  gh auth login --scopes repo"
echo ""
echo "Or set secrets manually in GitHub UI:"
echo "  https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

# Note: AZURE_CREDENTIALS should be created manually as a service principal
# See: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure
echo ""
echo "IMPORTANT: AZURE_CREDENTIALS must be set manually with Azure Service Principal JSON"
echo "Run this to create the service principal:"
echo ""
echo "  az ad sp create-for-rbac --name \"sp-github-$REPO_NAME\" \\"
echo "    --role contributor \\"
echo "    --scopes /subscriptions/\$(az account show --query id -o tsv)/resourceGroups/rg-dev-springai \\"
echo "    --sdk-auth"
echo ""
echo "Then copy the JSON output and set it manually via:"
echo "  gh secret set AZURE_CREDENTIALS -r $REPO_OWNER/$REPO_NAME"
echo ""
read -p "Press Enter to continue setting other secrets..."

echo "Setting ACR_LOGIN_SERVER..."
echo "$SECRETS" | jq -r '.value.ACR_LOGIN_SERVER' | gh secret set ACR_LOGIN_SERVER -r $REPO_OWNER/$REPO_NAME

echo "Setting ACR_USERNAME..."
echo "$SECRETS" | jq -r '.value.ACR_USERNAME' | gh secret set ACR_USERNAME -r $REPO_OWNER/$REPO_NAME

echo "Setting ACR_PASSWORD..."
echo "$SECRETS" | jq -r '.value.ACR_PASSWORD' | gh secret set ACR_PASSWORD -r $REPO_OWNER/$REPO_NAME

echo "Setting CONTAINER_APP_NAME..."
echo "$SECRETS" | jq -r '.value.CONTAINER_APP_NAME' | gh secret set CONTAINER_APP_NAME -r $REPO_OWNER/$REPO_NAME

echo "Setting RESOURCE_GROUP_NAME..."
echo "$SECRETS" | jq -r '.value.RESOURCE_GROUP_NAME' | gh secret set RESOURCE_GROUP_NAME -r $REPO_OWNER/$REPO_NAME

echo ""
echo "✅ Secrets set successfully!"
echo "⚠️  Don't forget to set AZURE_CREDENTIALS manually (see instructions above)"