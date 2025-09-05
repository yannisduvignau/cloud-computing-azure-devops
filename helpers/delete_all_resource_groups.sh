#!/bin/bash
# WARNING: This will delete ALL resource groups in your subscription!
# Use with caution.

set -e

echo "⚠️ WARNING: This will delete ALL resource groups in your Azure subscription!"
read -p "Type YES to confirm: " confirm

if [[ "$confirm" != "YES" ]]; then
    echo "❌ Aborted by user."
    exit 1
fi

# List all resource groups
RESOURCE_GROUPS=$(az group list --query "[].name" -o tsv)

if [[ -z "$RESOURCE_GROUPS" ]]; then
    echo "✅ No resource groups found."
    exit 0
fi

# Delete each resource group
for rg in $RESOURCE_GROUPS; do
    echo "🗑️ Deleting resource group: $rg"
    az group delete --name "$rg" --yes --no-wait
done

echo "✅ Deletion commands sent for all resource groups. They may take several minutes to complete."
