variable "resource_group_name" {
  description = "resource group for the VNET"
  type        = string
}

variable "location" {
  description = "Azure region, e.g. eastus"
  type        = string
}

variable "vnet_name" {
  description = "VNET name"
  type        = string
}

variable "address_space" {
  description = "VNET address space (CIDR blocks)"
  type        = list(string)
}

variable "dns_servers" {
  description = "custom DNS servers, empty for Azure default"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "subnets to create, each optionally with its own NSG rules and service endpoints"
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
  description = "attach a DDoS protection plan (paid, off by default)"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "DDoS plan ID, required if enable_ddos_protection is true"
  type        = string
  default     = null
}

variable "tags" {
  description = "tags applied to all resources this module creates"
  type        = map(string)
  default     = {}
}
