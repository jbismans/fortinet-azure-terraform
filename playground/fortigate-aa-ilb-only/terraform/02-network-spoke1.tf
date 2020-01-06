##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet_spoke1" {
  name                = "${var.PREFIX}-SPOKE1-VNET"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  address_space       = ["${var.vnet_spoke1}"]
}

# Frontend subnet
########################################################################################
resource "azurerm_subnet" "frontend_spoke1" {
  name                 = "${var.PREFIX}-SPOKE1-FRONTEND-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_spoke1.name}"
  address_prefix       = "${var.subnet_spoke1["frontend"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "frontend_spoke1_rt" {
  subnet_id      = "${azurerm_subnet.frontend_spoke1.id}"
  route_table_id = "${azurerm_route_table.frontend_spoke1_route.id}"
}

resource "azurerm_route_table" "frontend_spoke1_route" {
  name                = "${var.PREFIX}-SPOKE1-FRONTEND-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "Vnet-Hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_spoke1["frontend"]}"
    next_hop_type          = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = "${var.vnet_spoke1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = "${var.vnet_spoke2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }
}

# Middleware subnet
########################################################################################
resource "azurerm_subnet" "middleware_spoke1" {
  name                 = "${var.PREFIX}-SPOKE1-MIDDLEWARE-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_spoke1.name}"
  address_prefix       = "${var.subnet_spoke1["middleware"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "middleware_spoke1_rt" {
  subnet_id      = "${azurerm_subnet.middleware_spoke1.id}"
  route_table_id = "${azurerm_route_table.middleware_spoke1_route.id}"
}

resource "azurerm_route_table" "middleware_spoke1_route" {
  name                = "${var.PREFIX}-SPOKE1-MIDDLEWARE-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "Vnet-Hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_spoke1["middleware"]}"
    next_hop_type          = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = "${var.vnet_spoke1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = "${var.vnet_spoke2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }
}

# Backend subnet
########################################################################################
resource "azurerm_subnet" "backend_spoke1" {
  name                 = "${var.PREFIX}-SPOKE1-BACKEND-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_spoke1.name}"
  address_prefix       = "${var.subnet_spoke1["backend"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "backend_spoke1_rt" {
  subnet_id      = "${azurerm_subnet.backend_spoke1.id}"
  route_table_id = "${azurerm_route_table.backend_spoke1_route.id}"
}

resource "azurerm_route_table" "backend_spoke1_route" {
  name                = "${var.PREFIX}-SPOKE1-BACKEND-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "Vnet-Hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_spoke1["backend"]}"
    next_hop_type          = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = "${var.vnet_spoke1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = "${var.vnet_spoke2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_int_fgt_ipaddress_hub}"
  }
}