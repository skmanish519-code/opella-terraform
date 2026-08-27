output "vnet_id" {
  description = "Resource ID of the virtual network. Needed by peerings, private endpoints, or anything referencing this VNET from another module/state."
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}

output "address_space" {
  description = "Address space of the VNET, useful for downstream NSG/firewall rules that need to allow traffic from this network."
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet name => subnet resource ID. Consumers (VMs, App Services, private endpoints) look up the subnet they need by name instead of relying on list ordering."
  value       = { for name, s in azurerm_subnet.subnet : name => s.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet name => address prefixes, useful for documentation and for NSG rules elsewhere that need to allow a specific subnet's range."
  value       = { for name, s in azurerm_subnet.subnet : name => s.address_prefixes }
}

output "nsg_ids" {
  description = "Map of subnet name => NSG resource ID, for subnets that had create_nsg = true. Lets callers attach diagnostic settings or additional rules."
  value       = { for name, nsg in azurerm_network_security_group.nsg : name => nsg.id }
}
