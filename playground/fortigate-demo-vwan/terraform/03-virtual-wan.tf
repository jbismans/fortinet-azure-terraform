resource "azurerm_virtual_wan" "vwan" {
  name                = "${var.PREFIX}-VWAN"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  location             = "${var.LOCATION}"
}

resource "azurerm_virtual_hub" "vwan_hub" {
  name                 = "${var.PREFIX}-VWANHUB"
  resource_group_name  = "${azurerm_resource_group.resourcegroup.name}"
  location             = "${var.LOCATION}"
  virtual_wan_id       = azurerm_virtual_wan.vwan.id
  address_prefix       = "${var.address_prefix}"
}

