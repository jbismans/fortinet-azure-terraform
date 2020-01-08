##############################################################################################################
#
# Demo FortiGate loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet_spoke2" {
  name                = "${var.PREFIX}-SPOKE2-VNET"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  address_space       = ["${var.vnet_spoke2}"]
}

resource "azurerm_subnet" "subnet1_spoke2" {
  name                 = "${var.PREFIX}-SPOKE2-PROTECTED-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_spoke2.name}"
  address_prefix       = "${var.subnet_spoke2["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "subnet1_spoke2_rt" {
  subnet_id      = "${azurerm_subnet.subnet1_spoke2.id}"
  route_table_id = "${azurerm_route_table.protected_a_spoke2_route.id}"
}

resource "azurerm_route_table" "protected_a_spoke2_route" {
  name                = "${var.PREFIX}-SPOKE2-PROTECTED-A-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "Vnet-Hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = "${var.vnet_spoke1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = "${var.vnet_spoke2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }

  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_spoke2["1"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}
