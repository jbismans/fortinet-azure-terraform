##############################################################################################################
#
# Demo FortiGate loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet_hub" {
  name                = "${var.PREFIX}-HUB-VNET"
  address_space       = ["${var.vnet_hub}"]
  location            = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_subnet" "subnet1_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-EXTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["1"]}"
}

resource "azurerm_subnet" "subnet2_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-INTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["2"]}"
}

resource "azurerm_subnet" "subnet3_hub" {
  name                 = "${var.PREFIX}-HUB-PROTECTED-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["3"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet4_hub" {
  name                 = "${var.PREFIX}-HUB-PROTECTED-B-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["4"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "subnet3_hub_rt" {
  subnet_id      = "${azurerm_subnet.subnet3_hub.id}"
  route_table_id = "${azurerm_route_table.protected_a_hub_route.id}"
}

resource "azurerm_route_table" "protected_a_hub_route" {
  name                = "${var.PREFIX}-HUB-PROTECTED-A-RT"
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
    address_prefix         = "${var.subnet_hub["3"]}"
    next_hop_type          = "VnetLocal"
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}

resource "azurerm_subnet_route_table_association" "subnet4_hub_rt" {
  subnet_id      = "${azurerm_subnet.subnet4_hub.id}"
  route_table_id = "${azurerm_route_table.protected_b_hub_route.id}"
}

resource "azurerm_route_table" "protected_b_hub_route" {
  name                = "${var.PREFIX}-HUB-PROTECTED-B-RT"
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
    address_prefix         = "${var.subnet_hub["4"]}"
    next_hop_type          = "VnetLocal"
  }
  
  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}