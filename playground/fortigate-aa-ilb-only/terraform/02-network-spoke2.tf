##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet_spoke2" {
  name                = "${var.PREFIX}-SPOKE2-VNET"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  address_space       = [var.vnet_spoke2]
}

# Frontend subnet
########################################################################################
resource "azurerm_subnet" "frontend_spoke2" {
  name                 = "${var.PREFIX}-SPOKE2-FRONTEND-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke2.name
  address_prefixes     = [var.subnet_spoke2["frontend"]]
}

resource "azurerm_subnet_route_table_association" "frontend_spoke2_rt" {
  subnet_id      = azurerm_subnet.frontend_spoke2.id
  route_table_id = azurerm_route_table.frontend_spoke2_route.id
  lifecycle {
    ignore_changes = [route_table_id]
  }
}

resource "azurerm_route_table" "frontend_spoke2_route" {
  name                = "${var.PREFIX}-SPOKE2-FRONTEND-RT"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    name                   = "Vnet-Hub"
    address_prefix         = var.vnet_hub
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name           = "Subnet"
    address_prefix = var.subnet_spoke2["frontend"]
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = var.vnet_spoke1
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = var.vnet_spoke2
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }
}

# Middleware subnet
########################################################################################
resource "azurerm_subnet" "middleware_spoke2" {
  name                 = "${var.PREFIX}-SPOKE2-MIDDLEWARE-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke2.name
  address_prefixes     = [var.subnet_spoke2["middleware"]]
}

resource "azurerm_subnet_route_table_association" "middleware_spoke2_rt" {
  subnet_id      = azurerm_subnet.middleware_spoke2.id
  route_table_id = azurerm_route_table.middleware_spoke2_route.id
  lifecycle {
    ignore_changes = [route_table_id]
  }
}

resource "azurerm_route_table" "middleware_spoke2_route" {
  name                = "${var.PREFIX}-SPOKE2-MIDDLEWARE-RT"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    name                   = "Vnet-Hub"
    address_prefix         = var.vnet_hub
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name           = "Subnet"
    address_prefix = var.subnet_spoke2["middleware"]
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = var.vnet_spoke1
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = var.vnet_spoke2
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }
}

# Backend subnet
########################################################################################
resource "azurerm_subnet" "backend_spoke2" {
  name                 = "${var.PREFIX}-SPOKE2-BACKEND-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke2.name
  address_prefixes     = [var.subnet_spoke2["backend"]]
}

resource "azurerm_subnet_route_table_association" "backend_spoke2_rt" {
  subnet_id      = azurerm_subnet.backend_spoke2.id
  route_table_id = azurerm_route_table.backend_spoke2_route.id
  lifecycle {
    ignore_changes = [route_table_id]
  }
}

resource "azurerm_route_table" "backend_spoke2_route" {
  name                = "${var.PREFIX}-SPOKE2-BACKEND-RT"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name

  route {
    name                   = "Vnet-Hub"
    address_prefix         = var.vnet_hub
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name           = "Subnet"
    address_prefix = var.subnet_spoke2["backend"]
    next_hop_type  = "VnetLocal"
  }

  route {
    name                   = "Vnet-Spoke1"
    address_prefix         = var.vnet_spoke1
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Vnet-Spoke2"
    address_prefix         = var.vnet_spoke2
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.ilb_int_fgt_ipaddress_hub
  }
}