##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################
# HUB-SPOKE1
resource "azurerm_virtual_network_peering" "hub_to_spoke1" {
  name                      = "hub_to_spoke1"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_spoke1.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke1_to_hub" {
  name                      = "spoke1_to_hub"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_spoke1.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_hub.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# HUB-SPOKE2
resource "azurerm_virtual_network_peering" "hub_to_spoke2" {
  name                      = "hub_to_spoke2"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_hub.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_spoke2.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "spoke2_to_hub" {
  name                      = "spoke2_to_hub"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet_spoke2.name}"
  remote_virtual_network_id = "${azurerm_virtual_network.vnet_hub.id}"
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}