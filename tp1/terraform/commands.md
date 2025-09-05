# 1. Initialize the Terraform working directory
terraform init

# 2. Validate the configuration files
terraform validate

# 3. Preview the changes Terraform will make
terraform plan -out myplan

# 4. Apply the planned changes (create the VM)
terraform apply "myplan"

# 5. (Optional) Show the state of deployed resources
terraform show

# 6. (Optional) Destroy everything when done
terraform destroy -auto-approve
