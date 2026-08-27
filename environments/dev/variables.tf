variable "project" {
  description = "project name for naming/tagging"
  type        = string
  default     = "opella"
}

variable "environment" {
  description = "environment name (dev, prod, ...)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region, e.g. eastus"
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "short region code for names, e.g. eus for eastus"
  type        = string
  default     = "eus"
}

variable "address_space" {
  description = "VNET address space"
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "app_subnet_prefix" {
  description = "CIDR for the app subnet"
  type        = list(string)
  default     = ["10.10.1.0/24"]
}

variable "data_subnet_prefix" {
  description = "CIDR for the data subnet"
  type        = list(string)
  default     = ["10.10.2.0/24"]
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH into the VM - use your own IP/32, not 0.0.0.0/0"
  type        = string
  # no default - forces an explicit choice
}

variable "vm_size" {
  description = "VM SKU"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "admin username for the VM"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key" {
  description = "SSH public key for VM login, auto-generated if left empty"
  type        = string
  default     = ""
}

variable "owner" {
  description = "tag: team responsible for these resources"
  type        = string
  default     = "platform-team"
}

variable "cost_center" {
  description = "tag: cost center / chargeback code"
  type        = string
  default     = "eng-devops"
}
