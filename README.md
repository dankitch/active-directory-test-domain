<!-- BEGIN_TF_DOCS -->
# Deploys a baseline Active Directory Domain with Terraform

## Introduction

This Terraform configuration is designed to quickly spin up a test Active Directory domain. It automates the creation of the necessary resources in Azure, including a virtual network, relative subnets, a single DC, Win11 client (optional), Firewall, NAT Gateway, Bastion, all to provide a fully functional Active Directory environment for testing and development purposes.

Outbound internet connectivity is designed based on this tutorial:
https://learn.microsoft.com/en-us/azure/nat-gateway/tutorial-hub-spoke-nat-firewall

This deployment assumes total isolation from any existing networking infrastructure in your current Azure subscriptions. Whilst the networking resources included in this deployment may seem overkill for a test domain, I have found that in my experience, it allows one to become familiar with these resources and provides a solid baseline to test and build on, as well as being able to learn as you go. 

This should not be treated as a long-lived environment, and assumes that the resources are being deployed under one subscription, e.g., a Sandbox subscription, where resources can be created and destroyed at will. 

## Configuration

The inputs vars are defined in the `terraform.tfvars` file, which includes parameters such as the subscription ID, primary region, domain DNS name, and virtual network address space.
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.96.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.96.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.2 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_bastion_host.bastion](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host) | resource |
| [azurerm_firewall.firewall](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) | resource |
| [azurerm_nat_gateway.nat_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway) | resource |
| [azurerm_nat_gateway_public_ip_association.nat_ip_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/nat_gateway_public_ip_association) | resource |
| [azurerm_network_interface.dc_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.bastion_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.firewall_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip.nat_gateway_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.bastion_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.dc_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.firewall_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.nat_fw_subnet_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_virtual_machine_extension.install_ad](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_windows_virtual_machine.dc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_string.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [template_file.ADDS](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dc_domain_admin_password"></a> [dc\_domain\_admin\_password](#input\_dc\_domain\_admin\_password) | The password for the initial domain admin user. | `string` | n/a | yes |
| <a name="input_dc_domain_admin_username"></a> [dc\_domain\_admin\_username](#input\_dc\_domain\_admin\_username) | The username to be used as the initial domain admin user. | `string` | n/a | yes |
| <a name="input_dc_hostname"></a> [dc\_hostname](#input\_dc\_hostname) | The computer hostname, e.g., DC01. | `string` | n/a | yes |
| <a name="input_dc_safemode_administrator_password"></a> [dc\_safemode\_administrator\_password](#input\_dc\_safemode\_administrator\_password) | Referred to as the Directory Services Restore Mode (DSRM) administrator password. This is passed to the install\_ad\_domain\_services.ps1 script. | `string` | n/a | yes |
| <a name="input_domain_dnsname"></a> [domain\_dnsname](#input\_domain\_dnsname) | The name of the active directory domain e.g., dankitch.com | `string` | n/a | yes |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | The region where the resources will be deployed e.g., uksouth, ukwest, etc. | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The subscription id where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The address space for the virtual network. | `string` | n/a | yes |

## Outputs

No outputs.

## Useage

### Local testing ###

Assuming you are running terraform locally for testing:

1. Create a `.debug.tfvars` in the `root` directory and define the same input variables that are present in the `terraform.tfvars` file. 

`terraform init`

`terraform plan -var-file=".debug.tfvars"`

`terraform apply -var-file=".debug.tfvars"`

<!-- END_TF_DOCS -->
