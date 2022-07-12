##############################################################################################################
#
# FortiGate SD-WAN deployment
#
##############################################################################################################

# HUB-BRANCH1
resource "azurerm_virtual_network_peering" "hub_to_branch1" {
  name                      = "hub_to_branch1"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_branch1.id}"
}

resource "azurerm_virtual_network_peering" "branch1_to_hub" {
  name                      = "branch1_to_hub"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_branch1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_hub.id}"
}

# HUB-BRANCH2
resource "azurerm_virtual_network_peering" "hub_to_branch2" {
  name                      = "hub_to_branch2"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_branch2.id}"
}

resource "azurerm_virtual_network_peering" "branch2_to_hub" {
  name                      = "branch2_to_hub"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_branch2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_hub.id}"
}

# BRANCH1-BRANCH2
resource "azurerm_virtual_network_peering" "branch1_to_branch2" {
  name                      = "branch1_to_branch2"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_branch1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_branch2.id}"
}

resource "azurerm_virtual_network_peering" "branch2_to_branch1" {
  name                      = "branch2_to_branch1"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_branch2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_branch1.id}"
}