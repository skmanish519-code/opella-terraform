variable "project" {
  description = "Short project name used in resource naming and tagging."
  type        = string
  default     = "opella"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region, full name."
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short region code used in resource names."
  type        = string
  default     = "eus"
}

variable "address_space" {
  description = "VNET address space. Distinct range from dev so the two can be peered later without overlap."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "app_subnet_prefix" {
  type    = list(string)
  default = ["10.20.1.0/24"]
}

variable "data_subnet_prefix" {
  type    = list(string)
  default = ["10.20.2.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the prod VM. In practice this should be a bastion/VPN range, not a laptop IP."
  type        = string
}

variable "vm_size" {
  description = "VM SKU. Larger than dev's burstable size since prod needs consistent CPU."
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key content. Required in prod — unlike dev, this has no auto-generate fallback, since a Terraform-generated private key sitting in state is not acceptable for a production box."
  type        = string
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "cost_center" {
  type    = string
  default = "eng-devops"
}
