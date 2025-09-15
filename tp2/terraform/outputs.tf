output "public_ip_address" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN complet fourni par Azure (si domain_name_label renseigné)"
  value       = azurerm_public_ip.pip.fqdn
}


output "storage_account_primary_key" {
  description = "Primary access key for the storage account"
  value = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "storage_container_url" {
  value = azurerm_storage_container.container.id
}

# output "sas_token" {
#   value = azurerm_storage_account_sas.sas.sas
# }