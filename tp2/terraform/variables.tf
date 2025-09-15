variable "resource_group" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure location for the resources"
  type        = string
  default     = "uksouth"
}

variable "vm_name" {
  description = "Name of the VM"
  type        = string
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}

variable "vm_size" {
  description = "The size of the VM"
  type        = string
  default     = "Standard_B1s"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "your-subscription-id"
}

variable "dns_label" {
  description = "Label DNS pour la IP publique (doit être en minuscules, chiffres et tirets, unique au sein du cluster régional)"
  type        = string
  default     = ""
  validation {
    condition     = var.dns_label == "" || can(regex("^[a-z0-9-]{3,63}$", var.dns_label))
    error_message = "dns_label doit être vide ou respecter ^[a-z0-9-]{3,63}$ (minuscules, chiffres et tirets)."
  }
}