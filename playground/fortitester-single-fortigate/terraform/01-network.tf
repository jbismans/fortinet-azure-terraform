##############################################################################################################
#
# Fortitester internal throughput
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.PREFIX}-VNET"
  address_space       = ["${var.vnet}"]
  location            = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_subnet" "port1_subnet" {
  name                 = "${var.PREFIX}-PORT1-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "port2_subnet" {
  name                 = "${var.PREFIX}-PORT2-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["2"]}"
    lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "mgmt_subnet" {
  name                 = "${var.PREFIX}-MGMT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["3"]}"
}

resource "azurerm_subnet_route_table_association" "port1_subnet_rt" {
  subnet_id      = "${azurerm_subnet.port1_subnet.id}"
  route_table_id = "${azurerm_route_table.port1_subnet_rt.id}"
}

resource "azurerm_route_table" "port1_subnet_rt" {
  name                = "${var.PREFIX}-PORT1-SUBNET-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "ToPort2Subnet"
    address_prefix         = "${var.subnet["2"]}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["1"]}"
  }
}

resource "azurerm_subnet_route_table_association" "port2_subnet_rt" {
  subnet_id      = "${azurerm_subnet.port2_subnet.id}"
  route_table_id = "${azurerm_route_table.port2_subnet_rt.id}"
}

resource "azurerm_route_table" "port2_subnet_rt" {
  name                = "${var.PREFIX}-PORT2-SUBNET-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "ToPort1Subnet"
    address_prefix         = "${var.subnet["1"]}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["2"]}"
  }
}