variable "project" {
  description = "project name for naming/tagging"
  type        = string
  default     = "opella"
}

variable "environment" {
  description = "environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "short region code for names"
  type        = string
  default     = "eus"
}

variable "address_space" {
  description = "VNET address space, separate range from dev for future peering"
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
  description = "CIDR allowed to SSH into the VM - use a bastion/VPN range"
  type        = string
}

variable "vm_size" {
  description = "VM SKU, larger than dev since prod needs steady CPU"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key, required - no auto-generated fallback in prod"
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
