##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet_hub" {
  name                = "${var.PREFIX}-HUB-VNET"
  address_space       = ["${var.vnet_hub}"]
  location            = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

# FortiGate external subnet
#########################################################################################
resource "azurerm_subnet" "fgt_ext_ext_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-EXTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fgt_ext_wan"]}"
}

resource "azurerm_subnet" "fgt_ext_int_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-INTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fgt_ext_lan"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "fgt_ext_int_rt" {
  subnet_id      = "${azurerm_subnet.fgt_ext_int_hub.id}"
  route_table_id = "${azurerm_route_table.fgt_ext_int_route.id}"
}

resource "azurerm_route_table" "fgt_ext_int_route" {
  name                = "${var.PREFIX}-HUB-FGT-EXT-LAN-RT"
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
    address_prefix         = "${var.subnet_hub["fgt_ext_lan"]}"
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
}

resource "azurerm_subnet" "fgt_ext_hasync_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-HASYNC-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fgt_ext_hasync"]}"
}

resource "azurerm_subnet" "fgt_ext_mgmt_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-MGMT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fgt_ext_mgmt"]}"
}


# FortiGate internal subnet
#########################################################################################
resource "azurerm_subnet" "fgt_int_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-INT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fgt_int"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "fgt_int_hub_rt" {
  subnet_id      = "${azurerm_subnet.fgt_int_hub.id}"
  route_table_id = "${azurerm_route_table.fgt_int_hub_route.id}"
}

resource "azurerm_route_table" "fgt_int_hub_route" {
  name                = "${var.PREFIX}-HUB-FGT-INT-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "Default"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_ext_fgt_ipaddress_hub}"
  }
}

# Bastion subnet
#########################################################################################
resource "azurerm_subnet" "bastion_hub" {
  name                 = "${var.PREFIX}-HUB-BASTION-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["bastion"]}"
}

# DMZ External Shared Services subnet
########################################################################################
resource "azurerm_subnet" "dmz_ext_shrd_hub" {
  name                 = "${var.PREFIX}-HUB-DMZ-EXT-SHRD-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["dmz_ext_shrd"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "dmz_ext_shrd_hub_rt" {
  subnet_id      = "${azurerm_subnet.dmz_ext_shrd_hub.id}"
  route_table_id = "${azurerm_route_table.dmz_ext_shrd_route.id}"
}

resource "azurerm_route_table" "dmz_ext_shrd_route" {
  name                = "${var.PREFIX}-HUB-DMZ-EXT-SHRD-RT"
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
    address_prefix         = "${var.subnet_hub["dmz_ext_shrd"]}"
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

# Public DMZ subnet
########################################################################################
resource "azurerm_subnet" "dmz_pub_hub" {
  name                 = "${var.PREFIX}-HUB-DMZ-PUB-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["dmz_pub"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "dmz_pub_hub_rt" {
  subnet_id      = "${azurerm_subnet.dmz_pub_hub.id}"
  route_table_id = "${azurerm_route_table.dmz_pub_route.id}"
}

resource "azurerm_route_table" "dmz_pub_route" {
  name                = "${var.PREFIX}-HUB-DMZ-PUB-RT"
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
    address_prefix         = "${var.subnet_hub["dmz_pub"]}"
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

# DMZ Internal Shared Services subnet
########################################################################################
resource "azurerm_subnet" "dmz_int_shrd_hub" {
  name                 = "${var.PREFIX}-HUB-DMZ-INT-SHRD-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["dmz_int_shrd"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "dmz_int_shrd_hub_rt" {
  subnet_id      = "${azurerm_subnet.dmz_int_shrd_hub.id}"
  route_table_id = "${azurerm_route_table.dmz_int_shrd_route.id}"
}

resource "azurerm_route_table" "dmz_int_shrd_route" {
  name                = "${var.PREFIX}-HUB-DMZ-INT-SHRD-RT"
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
    address_prefix         = "${var.subnet_hub["dmz_int_shrd"]}"
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