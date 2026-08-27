module "vnet" {
  source = "../../"

  resource_group_name = "rg-example-dev-eastus"
  location             = "eastus"
  vnet_name            = "vnet-example-dev-eastus"
  address_space        = ["10.10.0.0/16"]

  subnets = [
    {
      name              = "snet-app-dev"
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      nsg_rules = [
        {
          name                        = "allow-ssh-from-office"
          priority                    = 100
          direction                   = "Inbound"
          access                      = "Allow"
          protocol                    = "Tcp"
          destination_port_range      = "22"
          source_address_prefix       = "203.0.113.0/24"
          destination_address_prefix  = "*"
        }
      ]
    },
    {
      name              = "snet-data-dev"
      address_prefixes  = ["10.10.2.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      # No custom rules: create_nsg still defaults to true, giving this
      # subnet a deny-by-default NSG with only Azure's baseline rules.
    }
  ]

  tags = {
    environment = "dev"
    project     = "opella"
    managed_by  = "terraform"
  }
}
