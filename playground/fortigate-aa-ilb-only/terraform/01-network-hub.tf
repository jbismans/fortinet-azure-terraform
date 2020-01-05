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

# FortiGate subnet
#########################################################################################
resource "azurerm_subnet" "fgt_hub" {
  name                 = "${var.PREFIX}-HUB-FGT-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["fortigate"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "fgt_hub_rt" {
  subnet_id      = "${azurerm_subnet.fgt_hub.id}"
  route_table_id = "${azurerm_route_table.fgt_hub_route.id}"
}

resource "azurerm_route_table" "fgt_hub_route" {
  name                = "${var.PREFIX}-HUB-FGT-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  # route {
  #   name                   = "Default"
  #   address_prefix         = "0.0.0.0/0"
  #   next_hop_type          = "VirtualAppliance"
  #   next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  # }
}

# Jumpstation subnet
#########################################################################################
resource "azurerm_subnet" "jumpstation_hub" {
  name                 = "${var.PREFIX}-HUB-JUMPSTATION-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
  address_prefix       = "${var.subnet_hub["jumpstation"]}"
}

# Checkpoint WAN subnet
#########################################################################################
# resource "azurerm_subnet" "chkp_wan_hub" {
#   name                 = "${var.PREFIX}-HUB-CHKP-WAN-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["checkpoint_wan"]}"
# }

# Checkpoint LAN subnet
#########################################################################################
# resource "azurerm_subnet" "chkp_lan_hub" {
#   name                 = "${var.PREFIX}-HUB-CHKP-LAN-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["checkpoint_lan"]}"
#   lifecycle {
#     ignore_changes = ["route_table_id"]
#   }
# }

# resource "azurerm_subnet_route_table_association" "chkp_lan_hub_rt" {
#   subnet_id      = "${azurerm_subnet.chkp_lan_hub.id}"
#   route_table_id = "${azurerm_route_table.chkp_lan_hub_route.id}"
# }

# resource "azurerm_route_table" "chkp_lan_hub_route" {
#   name                = "${var.PREFIX}-HUB-CHKP-LAN-RT"
#   location            = "${var.LOCATION}"
#   resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

#   route {
#     name                   = "Vnet-Hub"
#     address_prefix         = "${var.vnet_hub}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke1"
#     address_prefix         = "${var.vnet_spoke1}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke2"
#     address_prefix         = "${var.vnet_spoke2}"
#     next_hop_type          = "VirtualAppliance"
# #     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }
# }

# DMZ External subnet
#########################################################################################
# resource "azurerm_subnet" "dmz_ext_hub" {
#   name                 = "${var.PREFIX}-HUB-DMZ-EXT-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["dmz_external"]}"
#   lifecycle {
#     ignore_changes = ["route_table_id"]
#   }
# }

# resource "azurerm_subnet_route_table_association" "dmz_ext_hub_rt" {
#   subnet_id      = "${azurerm_subnet.dmz_ext_hub.id}"
#   route_table_id = "${azurerm_route_table.dmz_ext_hub_route.id}"
# }

# resource "azurerm_route_table" "dmz_ext_hub_route" {
#   name                = "${var.PREFIX}-HUB-DMZ-EXT-RT"
#   location            = "${var.LOCATION}"
#   resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

#   route {
#     name                   = "Vnet-Hub"
#     address_prefix         = "${var.vnet_hub}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke1"
#     address_prefix         = "${var.vnet_spoke1}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke2"
#     address_prefix         = "${var.vnet_spoke2}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Subnet"
#     address_prefix         = "${var.subnet_hub["dmz_external"]}"
#     next_hop_type          = "VnetLocal"
#   }

#   route {
#     name                   = "Default"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }
# }

# DMZ Internal subnet
#########################################################################################
# resource "azurerm_subnet" "dmz_int_hub" {
#   name                 = "${var.PREFIX}-HUB-DMZ-INT-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["dmz_internal"]}"
#   lifecycle {
#     ignore_changes = ["route_table_id"]
#   }
# }

# resource "azurerm_subnet_route_table_association" "dmz_int_hub_rt" {
#   subnet_id      = "${azurerm_subnet.dmz_int_hub.id}"
#   route_table_id = "${azurerm_route_table.dmz_int_hub_route.id}"
# }

# resource "azurerm_route_table" "dmz_int_hub_route" {
#   name                = "${var.PREFIX}-HUB-DMZ-INT-RT"
#   location            = "${var.LOCATION}"
#   resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

#   route {
#     name                   = "Vnet-Hub"
#     address_prefix         = "${var.vnet_hub}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke1"
#     address_prefix         = "${var.vnet_spoke1}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke2"
#     address_prefix         = "${var.vnet_spoke2}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Subnet"
#     address_prefix         = "${var.subnet_hub["dmz_internal"]}"
#     next_hop_type          = "VnetLocal"
#   }

#   route {
#     name                   = "Default"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }
# }

# F5 External subnet
#########################################################################################
# resource "azurerm_subnet" "f5_ext_hub" {
#   name                 = "${var.PREFIX}-HUB-F5-EXT-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["F5_external"]}"
#   lifecycle {
#     ignore_changes = ["route_table_id"]
#   }
# }

# resource "azurerm_subnet_route_table_association" "f5_ext_hub_rt" {
#   subnet_id      = "${azurerm_subnet.f5_ext_hub.id}"
#   route_table_id = "${azurerm_route_table.f5_ext_hub_route.id}"
# }

# resource "azurerm_route_table" "f5_ext_hub_route" {
#   name                = "${var.PREFIX}-HUB-F5-EXT-RT"
#   location            = "${var.LOCATION}"
#   resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

#   route {
#     name                   = "Vnet-Hub"
#     address_prefix         = "${var.vnet_hub}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke1"
#     address_prefix         = "${var.vnet_spoke1}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke2"
#     address_prefix         = "${var.vnet_spoke2}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Subnet"
#     address_prefix         = "${var.subnet_hub["F5_external"]}"
#     next_hop_type          = "VnetLocal"
#   }

#   route {
#     name                   = "Default"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }
# }

# F5 Internal subnet
#########################################################################################
# resource "azurerm_subnet" "f5_int_hub" {
#   name                 = "${var.PREFIX}-HUB-F5-INT-SUBNET"
#   resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
#   virtual_network_name = "${azurerm_virtual_network.vnet_hub.name}"
#   address_prefix       = "${var.subnet_hub["F5_internal"]}"
#   lifecycle {
#     ignore_changes = ["route_table_id"]
#   }
# }

# resource "azurerm_subnet_route_table_association" "f5_int_hub_rt" {
#   subnet_id      = "${azurerm_subnet.f5_int_hub.id}"
#   route_table_id = "${azurerm_route_table.f5_int_hub_route.id}"
# }

# resource "azurerm_route_table" "f5_int_hub_route" {
#   name                = "${var.PREFIX}-HUB-F5-INT-RT"
#   location            = "${var.LOCATION}"
#   resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

#   route {
#     name                   = "Vnet-Hub"
#     address_prefix         = "${var.vnet_hub}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke1"
#     address_prefix         = "${var.vnet_spoke1}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Vnet-Spoke2"
#     address_prefix         = "${var.vnet_spoke2}"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }

#   route {
#     name                   = "Subnet"
#     address_prefix         = "${var.subnet_hub["F5_internal"]}"
#     next_hop_type          = "VnetLocal"
#   }

#   route {
#     name                   = "Default"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
#   }
# }