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
  description = "DNS label for public IP (must be in tiny, figures and dashes, unique within the regional cluster)"
  type        = string
  default     = ""
  validation {
    condition     = var.dns_label == "" || can(regex("^[a-z0-9-]{3,63}$", var.dns_label))
    error_message = "dns_label must be empty or respect ^[a-z0-9-]{3,63}$ (tiny, figures and dashes)."
  }
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name (3-24 lowercase letters and numbers)"
  default     = "mystorageacct123"
}

variable "storage_container_name" {
  type        = string
  description = "Storage container name"
  default     = "mycontainer"
}

variable "prefix" {
  description = "Un préfixe pour nommer les ressources Azure."
  type        = string
  default     = "monprojet"
}