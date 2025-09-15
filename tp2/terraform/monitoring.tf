# CPU Alert Configuration
resource "azurerm_monitor_action_group" "email_alert" {
  name                = "ActionGroup-VM-CPU-Alert"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "ag-cpu"

  email_receiver {
    name          = "AdminEmail"
    email_address = "yannis.duvignau@efrei.net"
  }
}

resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "Alert-VM-High-CPU"
  resource_group_name = azurerm_resource_group.rg.name
  scopes              = [azurerm_linux_virtual_machine.vm.id]
  description         = "Alerte déclenchée lorsque le CPU de la VM dépasse 70%."
  severity            = 2 # Sévérité de 0 (critique) à 4 (verbeux)

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 70
  }

  window_size   = "PT5M"
  frequency     = "PT1M"
  auto_mitigate = true

  action {
    action_group_id = azurerm_monitor_action_group.email_alert.id
  }
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-vm-monitoring-${azurerm_resource_group.rg.name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# RAM Alert Configuration
resource "azurerm_monitor_scheduled_query_rules_alert" "memory_alert" {
  name                = "Alert-VM-Low-Memory"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  action {
    action_group  = [azurerm_monitor_action_group.email_alert.id]
    email_subject = "Alerte : Mémoire RAM faible sur la VM"
  }

  description            = "Déclenchée quand la RAM dispo est < 512MB."
  enabled                = true
  data_source_id         = azurerm_log_analytics_workspace.main.id
  frequency   = 5
  time_window = 5
  query                  = <<-QUERY
    Perf
    | where ObjectName == "Memory" and CounterName == "Available MBytes"
    | where Computer == "${azurerm_linux_virtual_machine.vm.name}"
    | summarize AggregatedValue = avg(CounterValue) by bin(TimeGenerated, 5m), Computer
    | where AggregatedValue < 512
  QUERY
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
  severity = 1
}