#!/bin/bash

if ! az account show > /dev/null 2>&1; then
    echo "❌ You are not connected to Azure. Please first execute 'az login'."
    exit 1
fi

echo "🔐 Azure Key Vault secret recovery script"
echo "-------------------------------------------------"

# --- STAGE 1 : Selection of the safe (Key Vault) ---
echo "Recovery of the list of safes..."

vaults=()
while IFS= read -r line; do
  vaults+=("$line")
done < <(az keyvault list --query "[].name" -o tsv)


if [ ${#vaults[@]} -eq 0 ]; then
    echo "No safe found in this subscription."
    exit 1
fi

PS3="Choose a safe (type the number) : "
select selected_vault in "${vaults[@]}"; do
    if [ -n "$selected_vault" ]; then
        echo "You have chosen the safe: $selected_vault"
        break
    else
        echo "Invalid choice. Please try again."
    fi
done

echo ""

# --- STAGE 2: Selection of secrecy ---
echo "Recovery of secrets for '$selected_vault'..."

secrets=()
while IFS= read -r line; do
  secrets+=("$line")
done < <(az keyvault secret list --vault-name "$selected_vault" --query "[].name" -o tsv)


if [ ${#secrets[@]} -eq 0 ]; then
    echo "No secrets found in the safe '$selected_vault'."
    exit 1
fi

PS3="Choose a secret (type the number): "
select selected_secret in "${secrets[@]}"; do
    if [ -n "$selected_secret" ]; then
        echo "You have chosen the secret : $selected_secret"
        break
    else
        echo "Invalid choice. Please try again."
    fi
done

echo ""

# --- STAGE 3 : Secret value display ---
echo "Recovery of the value of secrecy..."
SECRET_VALUE=$(az keyvault secret show --vault-name "$selected_vault" --name "$selected_secret" --query "value" -o tsv)

echo "----------------------------------------"
echo "Secret value '$selected_secret' :"
echo "$SECRET_VALUE"
echo "----------------------------------------"