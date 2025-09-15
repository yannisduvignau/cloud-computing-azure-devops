# # Storage Account
# resource "azurerm_storage_account" "storage" {
#   name                     = "blobstorage2025"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
  
#   tags = {
#     environment = "staging"
#   }
# }

# # Storage Container
# resource "azurerm_storage_container" "container" {
#   name                  = "vhds"
#   storage_account_id    = azurerm_storage_account.storage.id
#   container_access_type = "private"
# }

# resource "azurerm_storage_account_sas" "sas" {
#   connection_string = azurerm_storage_account.storage.primary_connection_string

#   https_only = true

#   start  = "2025-09-15"
#   expiry = "2025-12-31"

#   resource_types {
#     service   = false
#     container = true
#     object    = true
#   }

#   services {
#     blob  = true
#     queue = false
#     file  = false
#     table = false
#   }

#   permissions {
#     read    = true
#     write   = true
#     delete  = true
#     list    = true
#     add     = true
#     create  = true
#     update  = true
#   }
# }

resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_account_name}${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = var.storage_container_name
  storage_account_name = azurerm_storage_account.storage.name
  container_access_type = "private"
}

data "azurerm_virtual_machine" "data" {
  name                = azurerm_linux_virtual_machine.vm.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "vm_blob_access" {
  principal_id = data.azurerm_virtual_machine.data.identity[0].principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.storage.id

  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}