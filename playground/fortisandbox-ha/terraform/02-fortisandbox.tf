##############################################################################################################
#
# FortiSandbox HA
#
##############################################################################################################

# FSA-A

resource "azurerm_public_ip" "fsa_a_pip" {
  name                         = "${var.PREFIX}-FSA-A-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fsa-a-pip")}"
}

resource "azurerm_public_ip" "fsa_shared_pip" {
  name                         = "${var.PREFIX}-SHARED-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fsa-shared-pip")}"
}

resource "azurerm_network_interface" "fsa_a_external_ifc" {
  name                      = "${var.PREFIX}-FSA-A-EXTERNAL-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fsa_ipaddress["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fsa_a_pip.id}"
    primary                                 = true
  }

  ip_configuration {
    name                                    = "ipconfig2"
    subnet_id                               = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fsa_ipaddress["5"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fsa_shared_pip.id}"
  }
}

resource "azurerm_network_interface_security_group_association" "fsa_a_external_ifc_nsg" {
  network_interface_id      = "${azurerm_network_interface.fsa_a_external_ifc.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_network_interface" "fsa_a_internal_ifc" {
  name                      = "${var.PREFIX}-FSA-A-INTERNAL-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fsa_ipaddress["3"]}"
  }
}

resource "azurerm_network_interface_security_group_association" "fsa_a_internal_ifc_nsg" {
  network_interface_id      = "${azurerm_network_interface.fsa_a_internal_ifc.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_virtual_machine" "fsa_a_vm" {
  name                  = "${var.PREFIX}-FSA-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fsa_a_external_ifc.id}", "${azurerm_network_interface.fsa_a_internal_ifc.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fsa_a_external_ifc.id}"
  vm_size               = "${var.fsa_vmsize}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortisandbox_vm"
    sku       = "${var.IMAGESKU}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortisandbox_vm"
    name      = "${var.IMAGESKU}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FSA-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FSA-A-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FSA-A-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FSA-HA"
    vendor = "Fortinet"
  }
}

# FSA-B

resource "azurerm_public_ip" "fsa_b_pip" {
  name                         = "${var.PREFIX}-FSA-B-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fsa-b-pip")}"
}

#resource "azurerm_public_ip" "fsa_shared_pip" {
#  name                         = "${var.PREFIX}-SHARED-PIP"
#  location                     = "${var.LOCATION}"
#  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
#  allocation_method            = "Static"
#  sku                          = "Standard"
#  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fsa-shared-pip")}"
#}

resource "azurerm_network_interface" "fsa_b_external_ifc" {
  name                      = "${var.PREFIX}-FSA-B-EXTERNAL-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fsa_ipaddress["2"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fsa_b_pip.id}"
  }

#  ip_configuration {
#    name                                    = "ipconfig2"
#    subnet_id                               = "${azurerm_subnet.subnet1.id}"
#    private_ip_address_allocation           = "static"
#    private_ip_address                      = "${var.fsa_ipaddress["5"]}"
#    public_ip_address_id                    = "${azurerm_public_ip.fsa_shared_pip.id}"
#  }
}

resource "azurerm_network_interface_security_group_association" "fsa_b_external_ifc_nsg" {
  network_interface_id      = "${azurerm_network_interface.fsa_b_external_ifc.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_network_interface" "fsa_b_internal_ifc" {
  name                      = "${var.PREFIX}-FSA-B-INTERNAL-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fsa_ipaddress["4"]}"
  }
}

resource "azurerm_network_interface_security_group_association" "fsa_b_internal_ifc_nsg" {
  network_interface_id      = "${azurerm_network_interface.fsa_b_internal_ifc.id}"
  network_security_group_id = "${azurerm_network_security_group.nsg.id}"
}

resource "azurerm_virtual_machine" "fsa_b_vm" {
  name                  = "${var.PREFIX}-FSA-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fsa_b_external_ifc.id}", "${azurerm_network_interface.fsa_b_internal_ifc.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fsa_b_external_ifc.id}"
  vm_size               = "${var.fsa_vmsize}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortisandbox_vm"
    sku       = "${var.IMAGESKU}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortisandbox_vm"
    name      = "${var.IMAGESKU}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FSA-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FSA-B-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FSA-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FSA-HA"
    vendor = "Fortinet"
  }
}

#data "azurerm_public_ip" "fsa_a_pip" {
#  name                = "${azurerm_public_ip.fsa_a_pip.name}"
#  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
#}

#data "azurerm_public_ip" "fsa_b_pip" {
#  name                = "${azurerm_public_ip.fsa_b_pip.name}"
#  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
#}

#data "azurerm_public_ip" "fsa_shared_pip" {
#  name                = "${azurerm_public_ip.fsa_shared_pip.name}"
#  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
#}