#!/bin/bash

echo "--- Start of the deletion simulation ---"
echo "List of all the resources that would be deleted, grouped by group of resources :"
echo ""

current_sub_name=$(az account show --query name --output tsv)
echo "Scan : $current_sub_name"
echo "--------------------------------------------------"

az group list --query "[].name" -o tsv | while read -r group; do
  echo ""
  echo "## Resource group : $group"
  echo "--------------------------------------------------"

  resources=$(az resource list --resource-group "$group" --query "[].{Type:type, Name:name}" -o tsv)

  if [ -z "$resources" ]; then
    echo "   -> This group of resources is empty."
  else
    echo "$resources" | awk '{printf "   -> Type: %-45s Name: %s\n", $1, $2}'
  fi
done