##############################################################################################################
#
# FortiGate SD-WAN deployment
#
##############################################################################################################

##############################################################################################################
# BRANCH 1
##############################################################################################################
resource "azurerm_virtual_network" "vnet_branch1" {
  name                = "${var.PREFIX}-BRANCH1-VNET"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  address_space       = ["${var.vnet_branch1}"]
}

resource "azurerm_subnet" "subnet1_branch1" {
  name                 = "${var.PREFIX}-BRANCH1-EXTERNAL1-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch1.name}"
  address_prefix       = "${var.subnet_branch1["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet2_branch1" {
  name                 = "${var.PREFIX}-BRANCH1-EXTERNAL2-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch1.name}"
  address_prefix       = "${var.subnet_branch1["2"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet3_branch1" {
  name                 = "${var.PREFIX}-BRANCH1-INTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch1.name}"
  address_prefix       = "${var.subnet_branch1["3"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet4_branch1" {
  name                 = "${var.PREFIX}-BRANCH1-PROTECTED-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch1.name}"
  address_prefix       = "${var.subnet_branch1["4"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet5_branch1" {
  name                 = "${var.PREFIX}-BRANCH1-PROTECTED-B-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch1.name}"
  address_prefix       = "${var.subnet_branch1["5"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "subnet4_branch1_rt" {
  subnet_id      = "${azurerm_subnet.subnet4_branch1.id}"
  route_table_id = "${azurerm_route_table.protected_a_branch1_route.id}"
}

resource "azurerm_route_table" "protected_a_branch1_route" {
  name                = "${var.PREFIX}-BRANCH1-PROTECTED-A-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet_branch1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress_branch1["3"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_branch1["4"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "to-hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
  route {
    name                   = "to-branch2"
    address_prefix         = "${var.vnet_branch2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}

resource "azurerm_subnet_route_table_association" "subnet5_branch1_rt" {
  subnet_id      = "${azurerm_subnet.subnet5_branch1.id}"
  route_table_id = "${azurerm_route_table.protected_b_branch1_route.id}"
}

resource "azurerm_route_table" "protected_b_branch1_route" {
  name                = "${var.PREFIX}-BRANCH1-PROTECTED-B-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet_branch1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress_branch1["3"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_branch1["5"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "to-hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
  route {
    name                   = "to-branch2"
    address_prefix         = "${var.vnet_branch2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}

##############################################################################################################
# BRANCH 2
##############################################################################################################
resource "azurerm_virtual_network" "vnet_branch2" {
  name                = "${var.PREFIX}-BRANCH2-VNET"
  address_space       = ["${var.vnet_branch2}"]
  location            = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_subnet" "subnet1_branch2" {
  name                 = "${var.PREFIX}-BRANCH2-EXTERNAL1-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch2.name}"
  address_prefix       = "${var.subnet_branch2["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet2_branch2" {
  name                 = "${var.PREFIX}-BRANCH2-EXTERNAL2-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch2.name}"
  address_prefix       = "${var.subnet_branch2["2"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet3_branch2" {
  name                 = "${var.PREFIX}-BRANCH2-INTERNAL-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch2.name}"
  address_prefix       = "${var.subnet_branch2["3"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet4_branch2" {
  name                 = "${var.PREFIX}-BRANCH2-PROTECTED-A-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch2.name}"
  address_prefix       = "${var.subnet_branch2["4"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet" "subnet5_branch2" {
  name                 = "${var.PREFIX}-BRANCH2-PROTECTED-B-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_branch2.name}"
  address_prefix       = "${var.subnet_branch2["5"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

resource "azurerm_subnet_route_table_association" "subnet4_branch2_rt" {
  subnet_id      = "${azurerm_subnet.subnet4_branch2.id}"
  route_table_id = "${azurerm_route_table.protected_a_branch2_route.id}"
}

resource "azurerm_route_table" "protected_a_branch2_route" {
  name                = "${var.PREFIX}-BRANCH2-PROTECTED-A-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet_branch2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress_branch2["3"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_branch2["4"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "to-hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
  route {
    name                   = "to-branch1"
    address_prefix         = "${var.vnet_branch1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}

resource "azurerm_subnet_route_table_association" "subnet5_branch2_rt" {
  subnet_id      = "${azurerm_subnet.subnet5_branch2.id}"
  route_table_id = "${azurerm_route_table.protected_b_branch2_route.id}"
}

resource "azurerm_route_table" "protected_b_branch2_route" {
  name                = "${var.PREFIX}-BRANCH2-PROTECTED-B-RT"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"

  route {
    name                   = "VirtualNetwork"
    address_prefix         = "${var.vnet_branch2}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.fgt_ipaddress_branch2["3"]}"
  }
  route {
    name                   = "Subnet"
    address_prefix         = "${var.subnet_branch2["5"]}"
    next_hop_type          = "VnetLocal"
  }
  route {
    name                   = "to-hub"
    address_prefix         = "${var.vnet_hub}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
  route {
    name                   = "to-branch1"
    address_prefix         = "${var.vnet_branch1}"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "${var.ilb_internal_ipaddress_hub}"
  }
}