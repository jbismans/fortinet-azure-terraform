##############################################################################################################
#
# FortiADC Azure Demo
#
##############################################################################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.PREFIX}-FAD-VNET"
  address_space       = [var.vnet]
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_subnet" "subnet_external" {
  name                 = "${var.PREFIX}-FAD-EXTERNAL-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet["1"]
}

resource "azurerm_subnet" "subnet_internal" {
  name                 = "${var.PREFIX}-FAD-INTERNAL-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet["2"]
}

resource "azurerm_subnet" "subnet_protected_a" {
  name                 = "${var.PREFIX}-FAD-PROTECTED-A-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet["3"]
}

resource "azurerm_subnet" "subnet_protected_b" {
  name                 = "${var.PREFIX}-FAD-PROTECTED-B-SUBNET"
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet["4"]
}

