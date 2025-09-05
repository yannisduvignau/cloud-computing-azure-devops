#!/bin/bash
# Script to create an Azure VM with the Azure CLI using an Ed25519 SSH key
# Automatically creates the resource group if it doesn't exist
# Retrieves the public IP after VM creation

set -e

# --- Configuration ---
RESOURCE_GROUP="${1:-sandbox-rg}"        # Default: sandbox-rg
LOCATION="uksouth"
VM_NAME="${2:-SampleVM}"                 # Default: SampleVM
ADMIN_USERNAME="${3:-azureuser}"         # Default: azureuser
SSH_KEY_PATH="${4:-$HOME/.ssh/id_ed25519.pub}"  # Default Ed25519 public key
IMAGE="Ubuntu2204"
VM_SIZE="${5:-Standard_B1s}"          # Default: Standard_B1s

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install it first."
    exit 1
fi

# Check if SSH key exists
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo "❌ SSH public key not found at $SSH_KEY_PATH"
    exit 1
fi

# Check if the resource group exists
if ! az group show --name "$RESOURCE_GROUP" &> /dev/null; then
    echo "🛠 Resource group '$RESOURCE_GROUP' does not exist. Creating it..."
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --verbose
else
    echo "✅ Resource group '$RESOURCE_GROUP' already exists."
fi

# Create the VM
echo "🚀 Creating VM '$VM_NAME' in resource group '$RESOURCE_GROUP'..."
az vm create \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --name "$VM_NAME" \
  --image "$IMAGE" \
  --size "$VM_SIZE" \
  --admin-username "$ADMIN_USERNAME" \
  --ssh-key-values "$SSH_KEY_PATH" \
  --verbose

# Retrieve public IP
PUBLIC_IP=$(az vm list-ip-addresses \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" \
    -o tsv)

echo "✅ VM '$VM_NAME' created successfully!"
echo "🌐 Public IP: $PUBLIC_IP"
echo "You can connect with:"
echo "ssh $ADMIN_USERNAME@$PUBLIC_IP"
