variable "resource_group_name" {
  description = "Name of the resource group where the VNET will be created."
  type        = string
}

variable "location" {
  description = "Azure region for the VNET (e.g. eastus, westeurope)."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space (CIDR blocks) for the VNET."
  type        = list(string)
}

variable "dns_servers" {
  description = "Optional custom DNS servers for the VNET. Leave empty to use Azure-provided DNS."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Subnets to create in the VNET. Each can optionally define its own NSG rules and service endpoints."
  type = list(object({
    name               = string
    address_prefixes   = list(string)
    service_endpoints  = optional(list(string), [])
    create_nsg         = optional(bool, true)
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string # Inbound | Outbound
      access                     = string # Allow | Deny
      protocol                   = string # Tcp | Udp | * 
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), [])
  }))

  validation {
    condition     = length(var.subnets) > 0
    error_message = "At least one subnet must be defined."
  }
}

variable "enable_ddos_protection" {
  description = "Attach a DDoS protection plan to the VNET. Off by default - it's a paid, per-hour resource."
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "Resource ID of an existing DDoS protection plan. Required only when enable_ddos_protection is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to the VNET and every resource this module creates (subnets, NSGs)."
  type        = map(string)
  default     = {}
}
