##############################################################################################################
#
# ETEX FAC TESTING 
#
##############################################################################################################

##############################################################################################################
# FAC-A
##############################################################################################################

resource "azurerm_network_interface" "fac_a_ifc" {
  name                      = "${var.PREFIX}-FAC-A-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fac_ipaddress["1"]}"
  }
}

resource "azurerm_virtual_machine" "fac_a_vm" {
  name                  = "${var.PREFIX}-FAC-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fac_a_ifc.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fac_a_ifc.id}"
  vm_size               = "${var.fac_vmsize}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortiauthenticator-vm"
    sku       = "fortinet-fac-vm"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortiauthenticator-vm"
    name      = "fortinet-fac-vm"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FAC-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FAC-A-DATADISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    lun               = 0
    disk_size_gb      = "65" #needs to be at least 60gb in size
    managed_disk_type = "Standard_LRS"
  }

  #storage_data_disk {
  #  name              = "${var.PREFIX}-FAC-A-DATADISK"
  #  managed_disk_type = "Standard_LRS"
  #  create_option     = "Empty"
  #  lun               = 0
  #  disk_size_gb      = "30"
  #}

  os_profile {
    computer_name  = "${var.PREFIX}-FAC-A-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FAC-TEST"
    vendor = "Fortinet"
  }
}

##############################################################################################################
# FAC-B
##############################################################################################################

resource "azurerm_network_interface" "fac_b_ifc" {
  name                      = "${var.PREFIX}-FAC-B-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fac_ipaddress["2"]}"
  }
}

resource "azurerm_virtual_machine" "fac_b_vm" {
  name                  = "${var.PREFIX}-FAC-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fac_b_ifc.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fac_b_ifc.id}"
  vm_size               = "${var.fac_vmsize}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortiauthenticator-vm"
    sku       = "fortinet-fac-vm"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortiauthenticator-vm"
    name      = "fortinet-fac-vm"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FAC-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FAC-B-DATADISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    lun               = 0
    disk_size_gb      = "65"   
    managed_disk_type = "Standard_LRS"
  }

  #storage_data_disk {
  #  name              = "${var.PREFIX}-FAC-B-DATADISK"
  #  managed_disk_type = "Standard_LRS"
  #  create_option     = "Empty"
  #  lun               = 0
  #  disk_size_gb      = "30"
  #}

  os_profile {
    computer_name  = "${var.PREFIX}-FAC-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FAC-TEST"
    vendor = "Fortinet"
  }
}