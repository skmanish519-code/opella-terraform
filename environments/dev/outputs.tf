output "resource_group_name" {
  description = "Name of the dev resource group, for use by teammates running az cli commands or building a second stack against the same RG."
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "VNET resource ID, for future peering to a hub VNET or another environment."
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "Map of subnet name to ID, for anything provisioned later that needs to land in this VNET."
  value       = module.vnet.subnet_ids
}

output "vm_private_ip" {
  description = "Private IP of the dev VM, used to SSH in from within the VNET/VPN/Bastion."
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_ssh_private_key" {
  description = "Auto-generated SSH private key, only populated when ssh_public_key was left empty. Marked sensitive; retrieve with `terraform output -raw vm_ssh_private_key`. For anything beyond a throwaway dev box, supply your own key instead."
  value       = var.ssh_public_key == "" ? tls_private_key.generated[0].private_key_pem : null
  sensitive   = true
}

output "storage_account_name" {
  description = "Name of the dev storage account."
  value       = azurerm_storage_account.dev.name
}

output "storage_container_name" {
  description = "Blob container name inside the storage account."
  value       = azurerm_storage_container.dev.name
}
