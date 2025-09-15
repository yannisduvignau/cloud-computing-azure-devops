#!/bin/bash

SECRET_NAME="<Le nom de votre secret>"
VAULT_NAME="<Le nom de votre Key Vault>"

echo "--- Authentification avec l'identité managée de la VM ---"
az login --identity

echo ""
echo "--- Récupération du secret depuis le Key Vault ---"
SECRET_VALUE=$(az keyvault secret show --name "$SECRET_NAME" --vault-name "$VAULT_NAME" --query "value" -o tsv)

echo ""
echo "Le secret récupéré est : $SECRET_VALUE"