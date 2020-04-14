##############################################################################################################
#
# FortiADC Azure Demo
#
##############################################################################################################

##############################################################################################################
# Ubuntu A
##############################################################################################################

resource "azurerm_public_ip" "lnx_a_pip" {
  name                = "${var.PREFIX}-LNX-A-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "lnx-a-pip")
}

resource "azurerm_network_interface" "lnx_a_ifc" {
  name                          = "${var.PREFIX}-LNX-A-IFC"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = false
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_protected_a.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.lnx_ipaddress["1"]
    public_ip_address_id          = azurerm_public_ip.lnx_a_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "lnx_a_ifc_nsg" {
  network_interface_id      = azurerm_network_interface.lnx_a_ifc.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_virtual_machine" "lnx_a_vm" {
  name                  = "${var.PREFIX}-LNX-A-VM"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.lnx_a_ifc.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-LNX-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-LNX-A-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
    custom_data    = data.template_file.lnx_a_custom_data.rendered
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

  tags = {}
}

data "template_file" "lnx_a_custom_data" {
  template = file("${path.module}/customdata-lnx-a.tpl")

  vars = {}
}

##############################################################################################################
# Ubuntu B
##############################################################################################################

resource "azurerm_public_ip" "lnx_b_pip" {
  name                = "${var.PREFIX}-LNX-B-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "lnx-b-pip")
}

resource "azurerm_network_interface" "lnx_b_ifc" {
  name                          = "${var.PREFIX}-LNX-B-IFC"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = false
  enable_accelerated_networking = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_protected_b.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.lnx_ipaddress["2"]
    public_ip_address_id          = azurerm_public_ip.lnx_b_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "lnx_b_ifc_nsg" {
  network_interface_id      = azurerm_network_interface.lnx_b_ifc.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_virtual_machine" "lnx_b_vm" {
  name                  = "${var.PREFIX}-LNX-B-VM"
  location              = azurerm_resource_group.resourcegroup.location
  resource_group_name   = azurerm_resource_group.resourcegroup.name
  network_interface_ids = [azurerm_network_interface.lnx_b_ifc.id]
  vm_size               = var.lnx_vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-LNX-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-LNX-B-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
    custom_data    = data.template_file.lnx_b_custom_data.rendered
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

  tags = {}
}

data "template_file" "lnx_b_custom_data" {
  template = file("${path.module}/customdata-lnx-b.tpl")

  vars = {}
}

data "azurerm_public_ip" "lnx_a_pip" {
  name                = azurerm_public_ip.lnx_a_pip.name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

data "azurerm_public_ip" "lnx_b_pip" {
  name                = azurerm_public_ip.lnx_b_pip.name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

