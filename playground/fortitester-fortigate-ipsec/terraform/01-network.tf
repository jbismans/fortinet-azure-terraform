##############################################################################################################
#
# Fortitester IPsec throughput
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.PREFIX}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_subnet" "transit_subnet" {
  name                 = "${var.PREFIX}-TRANSIT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "lan_a_subnet" {
  name                 = "${var.PREFIX}-LAN-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["2"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "lan_b_subnet" {
  name                 = "${var.PREFIX}-LAN-B-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["3"]}"
    lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "mgmt_subnet" {
  name                 = "${var.PREFIX}-MGMT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["4"]}"
}

resource "azurerm_subnet_route_table_association" "lan_a_subnet_rt" {
  subnet_id      = "${azurerm_subnet.lan_a_subnet.id}"
  route_table_id = "${azurerm_route_table.lan_a_subnet_rt.id}"
}

resource "azurerm_route_table" "lan_a_subnet_rt" {
  name                = "${var.PREFIX}-LAN-A-SUBNET-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "ToLanBSubnet"
    address_prefix         = "${var.subnet["3"]}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_a_ipaddress["2"]}"
  }
}

resource "azurerm_subnet_route_table_association" "lan_b_subnet_rt" {
  subnet_id      = "${azurerm_subnet.lan_b_subnet.id}"
  route_table_id = "${azurerm_route_table.lan_b_subnet_rt.id}"
}

resource "azurerm_route_table" "lan_b_subnet_rt" {
  name                = "${var.PREFIX}-LAN-B-SUBNET-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "ToLanASubnet"
    address_prefix         = "${var.subnet["2"]}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_b_ipaddress["2"]}"
  }
}