variable "subscription_id" {
  type        = string
  description = "The subscription id where the resources will be deployed."
}
variable "primary_region" {
  type        = string
  description = "The region where the resources will be deployed e.g., uksouth, ukwest, etc."
}
variable "domain_dnsname" {
  type        = string
  description = "The name of the active directory domain e.g., dankitch.com"
}
variable "vnet_address_space" {
  type        = string
  description = "The address space for the virtual network."
}
variable "dc_domain_admin_username" {
  type = string
  validation {
    condition = alltrue([
      length(var.dc_domain_admin_username) >= 1,
      length(var.dc_domain_admin_username) <= 20,
      can(regex("^[a-zA-Z0-9]*$", var.dc_domain_admin_username)),
      !contains(["admin", "administrator"], lower(var.dc_domain_admin_username))
    ])
    error_message = "The admin_username must be between 1 and 20 characters long, only contain letters and numbers, and must not include the words 'admin' or 'administrator'."
  }
  description = "The username to be used as the initial domain admin user."
}
variable "dc_domain_admin_password" {
  type        = string
  sensitive   = true
  description = "The password for the initial domain admin user."
}

variable "dc_safemode_administrator_password" {
  type        = string
  sensitive   = true
  description = "Referred to as the Directory Services Restore Mode (DSRM) administrator password. This is passed to the install_ad_domain_services.ps1 script."
}

variable "dc_hostname" {
  type = string
  validation {
    condition = alltrue([
      length(var.dc_hostname) >= 1,
      length(var.dc_hostname) <= 15
    ])
    error_message = "The hostname must be between 1 and 15 chars."
  }
  description = "The computer hostname, e.g., DC01."
}




