##############################################################################################################
#
# ETEX FAC TESTING 
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.PREFIX}-VNET"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  address_space       = ["${var.vnet}"]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "${var.PREFIX}-EXTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.PREFIX}-INTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["2"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.PREFIX}-PROTECTED-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["3"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet4" {
  name                 = "${var.PREFIX}-PROTECTED-B-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet["4"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "subnet3_rt" {
  subnet_id      = "${azurerm_subnet.subnet3.id}"
  route_table_id = "${azurerm_route_table.protected_a_route.id}"
}

resource "azurerm_route_table" "protected_a_route" {
  name                = "${var.PREFIX}-PROTECTED-A-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["2"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet["3"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "DefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["2"]}"
  }
}

resource "azurerm_subnet_route_table_association" "subnet4_rt" {
  subnet_id      = "${azurerm_subnet.subnet4.id}"
  route_table_id = "${azurerm_route_table.protected_b_route.id}"
}

resource "azurerm_route_table" "protected_b_route" {
  name                = "${var.PREFIX}-PROTECTED-B-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["2"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet["4"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "DefaultRoute"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress["2"]}"
  }
}
