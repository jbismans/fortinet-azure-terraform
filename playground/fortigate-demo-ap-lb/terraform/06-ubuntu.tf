##############################################################################################################
#
# Demo FortiGate loadbalanced Active/Passive
#
##############################################################################################################

##############################################################################################################
# Ubuntu Spoke1
##############################################################################################################

resource "azurerm_network_interface" "lnx_spoke1_ifc" {
  name                          = "${var.PREFIX}-SPOKE1-LNX-IFC"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = false
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1_spoke1.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.lnx_ipaddress_spoke1["1"]
  }
}

resource "azurerm_network_interface_security_group_association" "lnx_spoke1_ifc_nsg" {
  network_interface_id      = azurerm_network_interface.lnx_spoke1_ifc.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_virtual_machine" "lnx_spoke1_vm" {
  name                  = "${var.PREFIX}-SPOKE1-LNX-VM"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.lnx_spoke1_ifc.id]
  vm_size               = var.lnx_vmsize_spoke1

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-SPOKE1-LNX-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-SPOKE1-LNX-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
    custom_data    = data.template_file.lnx_spoke1_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled = true
    storage_uri = format(
      "%s%s%s",
      "https://",
      lower(var.BOOTDIAG_STORAGE),
      ".blob.core.windows.net/",
    )
  }

  tags = {
    server   = "ubuntu"
    location = "spoke1"
  }
}

data "template_file" "lnx_spoke1_custom_data" {
  template = file("${path.module}/customdata-lnx-spoke1.tpl")

  vars = {}
}

##############################################################################################################
# Ubuntu Spoke2
##############################################################################################################

resource "azurerm_network_interface" "lnx_spoke2_ifc" {
  name                          = "${var.PREFIX}-SPOKE2-LNX-IFC"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = false
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1_spoke2.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.lnx_ipaddress_spoke2["1"]
  }
}

resource "azurerm_network_interface_security_group_association" "lnx_spoke2_ifc_nsg" {
  network_interface_id      = azurerm_network_interface.lnx_spoke2_ifc.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_virtual_machine" "lnx_spoke2_vm" {
  name                  = "${var.PREFIX}-SPOKE2-LNX-VM"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.lnx_spoke2_ifc.id]
  vm_size               = var.lnx_vmsize_spoke2

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-SPOKE2-LNX-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-SPOKE2-LNX-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
    custom_data    = data.template_file.lnx_spoke2_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled = true
    storage_uri = format(
      "%s%s%s",
      "https://",
      lower(var.BOOTDIAG_STORAGE),
      ".blob.core.windows.net/",
    )
  }

  tags = {
    server   = "ubuntu"
    location = "spoke2"
  }
}

data "template_file" "lnx_spoke2_custom_data" {
  template = file("${path.module}/customdata-lnx-spoke2.tpl")

  vars = {}
}

