resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.main.location
  name                = "vnet-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name


}

resource "azurerm_subnet" "dc_subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 8, 1)]
  name                 = "snet-domain-controllers-${var.primary_region}-${random_string.main.result}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name

}

resource "azurerm_subnet" "client_subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 8, 2)]
  name                 = "snet-win-clients-${var.primary_region}-${random_string.main.result}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name

}


resource "azurerm_subnet" "firewall_subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 10, 3)]
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "bastion_subnet" {
  depends_on           = [azurerm_virtual_network.vnet]
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 11, 4)]
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_public_ip" "firewall_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = "fw-pip-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

}

resource "azurerm_firewall" "firewall" {
  location            = azurerm_resource_group.main.location
  name                = "fw-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "AzureFirewallIpConfiguration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id

  }
  dns_servers       = [azurerm_network_interface.dc_nic.private_ip_address]
  dns_proxy_enabled = true
}

resource "azurerm_firewall_network_rule_collection" "base_rule_collection" {
  action              = "Allow"
  azure_firewall_name = azurerm_firewall.firewall.name
  name                = "base-rule-collection"
  priority            = 100
  resource_group_name = azurerm_resource_group.main.name
  rule {
    source_addresses = [
      azurerm_subnet.dc_subnet.address_prefixes[0],
      azurerm_subnet.client_subnet.address_prefixes[0]
    ]
    destination_addresses = ["*"]
    destination_ports = [
      "80",
      "443"
    ]
    name      = "allow-http-https"
    protocols = ["TCP"]
  }
  rule {
    source_addresses      = [azurerm_subnet.client_subnet.address_prefixes[0]]
    destination_addresses = [azurerm_network_interface.dc_nic.private_ip_address]
    destination_ports     = ["53"]
    name                  = "allow-dns"
    protocols = [
      "TCP",
      "UDP"
    ]
  }

}

resource "azurerm_public_ip" "nat_gateway_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = "nat-gw-pip-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gateway" {
  location            = azurerm_resource_group.main.location
  name                = "nat-gw-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name

}

resource "azurerm_nat_gateway_public_ip_association" "nat_ip_association" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gateway.id
  public_ip_address_id = azurerm_public_ip.nat_gateway_pip.id

}

resource "azurerm_subnet_nat_gateway_association" "nat_fw_subnet_association" {
  nat_gateway_id = azurerm_nat_gateway.nat_gateway.id
  subnet_id      = azurerm_subnet.firewall_subnet.id
}

resource "azurerm_route_table" "route_table" {
  location            = azurerm_resource_group.main.location
  name                = "rt-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name


  route = [{
    address_prefix         = "0.0.0.0/0"
    name                   = "route-to-vnet-${var.primary_region}-${random_string.main.result}"
    next_hop_in_ip_address = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
    next_hop_type          = "VirtualAppliance"
  }]
}

resource "azurerm_subnet_route_table_association" "dc_subnet_route_table_association" {
  route_table_id = azurerm_route_table.route_table.id
  subnet_id      = azurerm_subnet.dc_subnet.id

}

resource "azurerm_subnet_route_table_association" "win_clients_subnet_route_table_association" {
  route_table_id = azurerm_route_table.route_table.id
  subnet_id      = azurerm_subnet.client_subnet.id
  
  
}



resource "azurerm_public_ip" "bastion_pip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.main.location
  name                = "bas-pip-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "Standard"

}

resource "azurerm_bastion_host" "bastion" {
  location            = azurerm_resource_group.main.location
  name                = "bas-${var.primary_region}-${random_string.main.result}"
  resource_group_name = azurerm_resource_group.main.name
  ip_configuration {
    name                 = "bastion-pip"
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
    subnet_id            = azurerm_subnet.bastion_subnet.id
  }

}
