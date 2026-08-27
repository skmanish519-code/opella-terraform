# Uses Terraform's built-in test framework (>= 1.6). Runs `terraform test`
# from the module root. All runs use `command = plan` so no real Azure
# credentials or resources are required in CI for plain PR checks.

mock_provider "azurerm" {}

variables {
  resource_group_name = "rg-test-dev-eastus"
  location             = "eastus"
  vnet_name            = "vnet-test-dev-eastus"
  address_space        = ["10.20.0.0/16"]

  subnets = [
    {
      name              = "snet-app"
      address_prefixes  = ["10.20.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      nsg_rules = [
        {
          name                       = "allow-https"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name              = "snet-data"
      address_prefixes  = ["10.20.2.0/24"]
      create_nsg        = false
    }
  ]

  tags = {
    environment = "test"
    project     = "opella"
  }
}

run "creates_expected_subnets" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.subnet) == 2
    error_message = "Expected exactly 2 subnets to be planned"
  }
}

run "nsg_only_created_when_requested" {
  command = plan

  assert {
    condition     = length(azurerm_network_security_group.nsg) == 1
    error_message = "Only snet-app requests an NSG (create_nsg defaults to true); snet-data explicitly disables it"
  }
}

run "nsg_rule_attached_to_correct_subnet" {
  command = plan

  assert {
    condition     = azurerm_network_security_rule.rule["snet-app-allow-https"].destination_port_range == "443"
    error_message = "The allow-https rule must target port 443"
  }
}

run "rejects_empty_subnet_list" {
  command = plan

  variables {
    subnets = []
  }

  expect_failures = [
    var.subnets,
  ]
}
