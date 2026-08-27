output "resource_group_name" {
  description = "dev resource group name"
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "VNET resource ID"
  value       = module.vnet.vnet_id
}

output "subnet_ids" {
  description = "subnet name -> ID"
  value       = module.vnet.subnet_ids
}

output "vm_private_ip" {
  description = "private IP of the dev VM"
  value       = azurerm_network_interface.vm.private_ip_address
}

output "vm_ssh_private_key" {
  description = "auto-generated SSH private key (only set if ssh_public_key was left empty)"
  value       = var.ssh_public_key == "" ? tls_private_key.generated[0].private_key_pem : null
  sensitive   = true
}

output "storage_account_name" {
  description = "dev storage account name"
  value       = azurerm_storage_account.dev.name
}

output "storage_container_name" {
  description = "blob container name"
  value       = azurerm_storage_container.dev.name
}
