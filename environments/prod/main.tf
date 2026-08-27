locals {
  name_prefix = "${var.project}-${var.environment}-${var.location_short}"

  common_tags = {
    environment = var.environment
    project     = var.project
    managed_by  = "terraform"
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# same module as dev, different inputs
module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  vnet_name            = "vnet-${local.name_prefix}"
  address_space        = var.address_space
  tags                 = local.common_tags

  subnets = [
    {
      name              = "snet-app-${var.environment}"
      address_prefixes  = var.app_subnet_prefix
      service_endpoints = ["Microsoft.Storage"]
      nsg_rules = [
        {
          name                       = "allow-ssh-restricted"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "22"
          source_address_prefix      = var.allowed_ssh_cidr
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name              = "snet-data-${var.environment}"
      address_prefixes  = var.data_subnet_prefix
      service_endpoints = ["Microsoft.Storage"]
    }
  ]
}

resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-${local.name_prefix}-01"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  tags                 = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["snet-app-${var.environment}"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "app" {
  name                   = "vm-${local.name_prefix}-01"
  resource_group_name   = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  size                   = var.vm_size
  admin_username         = var.admin_username
  network_interface_ids  = [azurerm_network_interface.vm.id]
  tags                   = local.common_tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS" # higher-durability disk tier for prod
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  disable_password_authentication = true
}

resource "random_string" "storage_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_storage_account" "app" {
  name                = lower(substr("st${var.project}${var.environment}${var.location_short}${random_string.storage_suffix.result}", 0, 24))
  resource_group_name = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  tags                 = local.common_tags

  account_tier             = "Standard"
  account_replication_type = "GRS" # geo-redundant in prod, unlike dev's LRS
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [module.vnet.subnet_ids["snet-data-${var.environment}"]]
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_storage_container" "app" {
  name                  = "app-data"
  storage_account_name  = azurerm_storage_account.app.name
  container_access_type = "private"
}
