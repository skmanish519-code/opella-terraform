output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = module.vnet.vnet_id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}

output "vm_private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "storage_account_name" {
  value = azurerm_storage_account.app.name
}
