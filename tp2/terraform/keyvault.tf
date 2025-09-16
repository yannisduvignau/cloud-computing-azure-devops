data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "vault" {
  name                       = "kv-${var.prefix}-${random_string.main.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
    ]
  }

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = azurerm_linux_virtual_machine.vm.identity[0].principal_id
    secret_permissions = ["Get"]
  }
}

resource "azurerm_key_vault_secret" "vault_secret" {
  name         = "${var.prefix}-super-secret-${random_string.main.result}"
  value        = random_password.secret.result
  key_vault_id = azurerm_key_vault.vault.id
}