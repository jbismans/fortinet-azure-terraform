##############################################################################################################
#
# FortiGate SD-WAN deployment
#
##############################################################################################################

##############################################################################################################
# FMG
##############################################################################################################
resource "azurerm_virtual_network" "vnet_fmg" {
  name                = "${var.PREFIX}-FMG-VNET"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  address_space       = ["${var.vnet_fmg}"]
}

resource "azurerm_subnet" "subnet1_fmg" {
  name                 = "${var.PREFIX}-FMG-SUBNET"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet_fmg.name}"
  address_prefix       = "${var.subnet_fmg["1"]}"
  lifecycle {
    ignore_changes = ["route_table_id"]
  }
}

