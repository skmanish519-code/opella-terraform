output "vnet_id" {
  description = "VNET resource ID"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "VNET name"
  value       = azurerm_virtual_network.vnet.name
}

output "address_space" {
  description = "VNET address space"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "subnet name -> subnet ID"
  value       = { for name, s in azurerm_subnet.subnet : name => s.id }
}

output "subnet_address_prefixes" {
  description = "subnet name -> address prefixes"
  value       = { for name, s in azurerm_subnet.subnet : name => s.address_prefixes }
}

output "nsg_ids" {
  description = "subnet name -> NSG ID, only for subnets that have one"
  value       = { for name, nsg in azurerm_network_security_group.nsg : name => nsg.id }
}
