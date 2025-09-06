output "public_ip_address" {
  description = "Adresse IP publique de la VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_fqdn" {
  description = "FQDN complet fourni par Azure (si domain_name_label renseigné)"
  value       = azurerm_public_ip.pip.fqdn
}