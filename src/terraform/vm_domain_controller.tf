resource "azurerm_network_interface" "dc_nic" {
  location            = azurerm_resource_group.main.location
  name                = "${var.dc_hostname}-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(azurerm_subnet.dc_subnet.address_prefixes[0], 5)
    subnet_id                     = azurerm_subnet.dc_subnet.id

  }


}

resource "azurerm_windows_virtual_machine" "dc" {
  admin_username                                         = var.dc_domain_admin_username
  admin_password                                         = var.dc_domain_admin_password
  location                                               = azurerm_resource_group.main.location
  name                                                   = "${var.dc_hostname}-${var.primary_region}-${random_string.main.result}"
  computer_name                                          = var.dc_hostname
  network_interface_ids                                  = azurerm_network_interface.dc_nic[*].id
  resource_group_name                                    = azurerm_resource_group.main.name
  size                                                   = "Standard_B2ms"
  allow_extension_operations                             = true
  enable_automatic_updates                               = true
  patch_assessment_mode                                  = "AutomaticByPlatform"
  patch_mode                                             = "AutomaticByPlatform"
  bypass_platform_safety_checks_on_user_schedule_enabled = true
  license_type                                           = "Windows_Server"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 200
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

#Install Active Directory on the DC01 VM
resource "azurerm_virtual_machine_extension" "install_ad" {
  name                 = "install_ad"
  virtual_machine_id   = azurerm_windows_virtual_machine.dc.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {    
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath ADDS.ps1\" && powershell -ExecutionPolicy Unrestricted -File ADDS.ps1 -Domain_DNSName ${data.template_file.ADDS.vars.Domain_DNSName} -Domain_NETBIOSName ${data.template_file.ADDS.vars.Domain_NETBIOSName} -SafeModeAdministratorPassword ${data.template_file.ADDS.vars.SafeModeAdministratorPassword}"
  }
  SETTINGS
}

locals {
  netbios_name = upper(replace(regex("[^.]+", var.domain_dnsname), "[^a-zA-Z0-9]", ""))
}

#Variable input for the install_ad_domain_services.ps1 script
data "template_file" "ADDS" {
  template = file("install_ad_domain_services.ps1")
  vars = {
    Domain_DNSName                = "${var.domain_dnsname}"
    Domain_NETBIOSName            = "${local.netbios_name}"
    SafeModeAdministratorPassword = "${var.dc_safemode_administrator_password}"
  }
}
