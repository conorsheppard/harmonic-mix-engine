#!/bin/bash
# One-time bootstrap for the Terraform azurerm remote-state backend.
#
# Creates the resource group, storage account and blob container that hold
# terraform.tfstate, then writes terraform/config.azurerm.tfbackend. That file
# is committed (a storage account name is not a secret) so every machine can:
#
#   cd terraform
#   terraform init -backend-config=config.azurerm.tfbackend
#
# Run this ONCE (on the first machine). Requires `az login` beforehand.
# Re-running is safe: existing resources are reused and the account name is kept.
set -euo pipefail

LOCATION="${LOCATION:-westeurope}"
STATE_RG="${STATE_RG:-harmonic-mix-engine-tfstate-rg}"
CONTAINER="${CONTAINER:-tfstate}"
STATE_KEY="${STATE_KEY:-harmonic.tfstate}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_FILE="$(cd "$SCRIPT_DIR/../.." && pwd)/terraform/config.azurerm.tfbackend"

command -v az >/dev/null 2>&1 || { echo "ERROR: Azure CLI (az) not found." >&2; exit 1; }
az account show >/dev/null 2>&1 || { echo "ERROR: not logged in. Run 'az login' first." >&2; exit 1; }

# Reuse the storage account name if we've bootstrapped before; otherwise mint a
# new globally-unique one (3-24 chars, lowercase alphanumeric).
if [[ -f "$BACKEND_FILE" ]] && grep -q storage_account_name "$BACKEND_FILE"; then
  STORAGE_ACCOUNT="$(grep storage_account_name "$BACKEND_FILE" | sed -E 's/.*"(.*)".*/\1/')"
  echo "Reusing storage account from existing backend config: $STORAGE_ACCOUNT"
else
  SUFFIX="$(head -c 32 /dev/urandom | tr -dc 'a-z0-9' | head -c 6)"
  STORAGE_ACCOUNT="hmetfstate${SUFFIX}"
  echo "Generated storage account name: $STORAGE_ACCOUNT"
fi

echo "==> Creating resource group '$STATE_RG' in '$LOCATION'..."
az group create --name "$STATE_RG" --location "$LOCATION" --output none

echo "==> Creating storage account '$STORAGE_ACCOUNT'..."
az storage account create \
  --name "$STORAGE_ACCOUNT" \
  --resource-group "$STATE_RG" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --encryption-services blob \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --output none

echo "==> Creating blob container '$CONTAINER'..."
az storage container create \
  --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" \
  --auth-mode login \
  --output none

echo "==> Writing $BACKEND_FILE"
cat > "$BACKEND_FILE" <<EOF
resource_group_name  = "$STATE_RG"
storage_account_name = "$STORAGE_ACCOUNT"
container_name       = "$CONTAINER"
key                  = "$STATE_KEY"
EOF

echo
echo "Done. Next:"
echo "  cd terraform"
echo "  terraform init -backend-config=config.azurerm.tfbackend"
