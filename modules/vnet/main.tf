locals {
  nsg_subnets = { for s in var.subnets : s.name => s if s.create_nsg }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = length(var.dns_servers) > 0 ? var.dns_servers : null

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos_protection ? [1] : []
    content {
      id     = var.ddos_protection_plan_id
      enable = true
    }
  }

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each = { for s in var.subnets : s.name => s }

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}

resource "azurerm_network_security_group" "nsg" {
  for_each = local.nsg_subnets

  name                = "nsg-${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_security_rule" "rule" {
  # flatten subnet -> rule pairs into one map, one resource instance per rule
  for_each = {
    for pair in flatten([
      for s in var.subnets : [
        for r in s.nsg_rules : {
          key        = "${s.name}-${r.name}"
          subnet_key = s.name
          rule       = r
        }
      ] if s.create_nsg
    ]) : pair.key => pair
  }

  name                        = each.value.rule.name
  priority                    = each.value.rule.priority
  direction                   = each.value.rule.direction
  access                      = each.value.rule.access
  protocol                    = each.value.rule.protocol
  source_port_range           = each.value.rule.source_port_range
  destination_port_range      = each.value.rule.destination_port_range
  source_address_prefix       = each.value.rule.source_address_prefix
  destination_address_prefix  = each.value.rule.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.subnet_key].name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = local.nsg_subnets

  subnet_id                 = azurerm_subnet.subnet[each.value.name].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.name].id
}
