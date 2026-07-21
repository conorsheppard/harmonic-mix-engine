variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to deploy into. Can also be supplied via ARM_SUBSCRIPTION_ID."
}

variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "West Europe"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used to name resources."
  default     = "harmonic-mix-engine"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size for the Minikube host."
  default     = "Standard_B2ls_v2"
}

variable "admin_username" {
  type        = string
  description = "Admin (SSH) username on the VM."
  default     = "azureuser"
}

variable "git_repo_url" {
  type        = string
  description = "Public Git repo cloned onto the VM during cloud-init."
  default     = "https://github.com/conorsheppard/harmonic-mix-engine.git"
}

variable "git_branch" {
  type        = string
  description = "Git branch to check out on the VM."
  default     = "main"
}

variable "ssh_source_address_prefix" {
  type        = string
  description = "CIDR/IP allowed to reach SSH (port 22). Defaults to any; narrow to your IP for tighter security."
  default     = "*"
}
