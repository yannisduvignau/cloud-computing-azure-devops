#!/bin/bash
# run_terraform_remote.sh
# Run Terraform plan and apply in a relative directory

set -e

# --- Configuration ---
TF_REL_DIR="${1:-terraform}"  # Default relative path: ./terraform
PLAN_FILE="myplan"

# Resolve the absolute path from the relative path
TF_DIR="$(realpath "$TF_REL_DIR")"

# Check if the target directory exists
if [[ ! -d "$TF_DIR" ]]; then
    echo "❌ Terraform directory '$TF_DIR' does not exist."
    exit 1
fi

# Move into the Terraform directory
pushd "$TF_DIR" > /dev/null

# Initialize Terraform (reconfigure in case backend changed)
echo "🚀 Initializing Terraform in $TF_DIR..."
terraform init -reconfigure -upgrade

# Generate plan
echo "📝 Creating Terraform plan..."
terraform plan -out "$PLAN_FILE"

# Apply plan
echo "⚡ Applying Terraform plan..."
terraform apply "$PLAN_FILE"

# Return to original directory
popd > /dev/null

echo "✅ Terraform apply completed in $TF_DIR"
