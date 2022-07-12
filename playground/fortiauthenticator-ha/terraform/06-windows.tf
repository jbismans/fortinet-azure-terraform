##############################################################################################################
#
# ETEX FAC TESTING 
#
##############################################################################################################

##############################################################################################################
# Windows Server
##############################################################################################################

resource "azurerm_network_interface" "win_server_ifc" {
  name                            = "${var.PREFIX}-WIN-SRV-IFC"
  location                        = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name             = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding            = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.vm_ipaddress["1"]}"
  }
}

resource "azurerm_virtual_machine" "win_server_vm" {
  name                  = "${var.PREFIX}-WIN-SRV-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.win_server_ifc.id}"]
  vm_size               = "${var.vm_vmsize}"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-smalldisk"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-WIN-SRV-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "WindowsServer"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = {
    environment = "FAC-TEST"
  }
}

##############################################################################################################
# Windows Client
##############################################################################################################

resource "azurerm_network_interface" "win_client_ifc" {
  name                            = "${var.PREFIX}-WIN-CLNT-IFC"
  location                        = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name             = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding            = false

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.vm_ipaddress["2"]}"
  }
}

resource "azurerm_virtual_machine" "win_client_vm" {
  name                  = "${var.PREFIX}-WIN-CLNT-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.win_client_ifc.id}"]
  vm_size               = "${var.vm_vmsize}"

  storage_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "19h1-pro"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-WIN-CLNT-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "WindowsClient"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_windows_config {
    provision_vm_agent        = true
    enable_automatic_upgrades = true
  }

  tags = {
    environment = "FAC-TEST"
  }
}
