#!/bin/bash

# --- Stage 0 : Warnings and confirmations ---
echo "Please note: this script will delete all the locks and all resource groups from the active subscription."
read -p "Are you absolutely sure you want to continue? (yes/no)" -r
if [[ ! $REPLY =~ ^[yY][eE][sS]$ ]]; then
    echo "Operation canceled."
    exit 1
fi

current_sub_name=$(az account show --query name --output tsv)
echo "The subscription '$current_sub_name' will be fully cleaned (locks included)."
read -p "Please confirm one last time. (yes/no)" -r
if [[ ! $REPLY =~ ^[yY][eE][sS]$ ]]; then
    echo "Operation canceled."
    exit 1
fi

# --- Stage 1 : Deletion of all locks ---
echo ""
echo "Launch of the removal of all locks ..."
az lock list --query "[].id" -o tsv | while read -r lock_id; do
  if [ -n "$lock_id" ]; then
    echo "--> Deletion of the lock : $lock_id"
    az lock delete --ids "$lock_id"
  fi
done
echo "All locks have been deleted."
echo ""


# --- Stage 2 : Deletion of all resource groups ---
echo "Launch of the abolition of all resource groups ..."
az group list --query "[].name" -o tsv | while read -r group_name; do
  if [ -n "$group_name" ]; then
    echo "--> Launch of the removal for the group : '$group_name'"
    # az group delete --name "$group_name" --yes --no-wait
    az group delete --name "$group_name" --yes
  fi
done

echo ""
echo "All deletion commands have been launched."