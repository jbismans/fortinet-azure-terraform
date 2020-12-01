##############################################################################################################
#
# FortiADC Azure Demo
#
##############################################################################################################

resource "azurerm_availability_set" "fad_hub_avset" {
  name                = "${var.PREFIX}-HUB-FAD-AVSET"
  location            = var.LOCATION
  managed             = true
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_network_security_group" "fad_nsg" {
  name                = "${var.PREFIX}-FAD-NSG"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_network_security_rule" "fad_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fad_nsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fad_nsg_allowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fad_nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "fad_floating_pip" {
  name                = "${var.PREFIX}-FAD-FLOATING-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "fad-floating-pip")
}

resource "azurerm_public_ip" "fad_a_pip" {
  name                = "${var.PREFIX}-FAD-A-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "fad-a-pip")
}

resource "azurerm_public_ip" "fad_b_pip" {
  name                = "${var.PREFIX}-FAD-B-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "fad-b-pip")
}

resource "azurerm_storage_account" "bootdiag_storage" {
  name                     = lower(var.BOOTDIAG_STORAGE)
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  location                 = var.LOCATION
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

##############################################################################################################
# FortiADC A
##############################################################################################################

resource "azurerm_network_interface" "fad_a_ifc_ext" {
  name                 = "${var.PREFIX}-FAD-A-IFC-EXT"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_external.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fad_ipaddress_a["1"]
    public_ip_address_id          = azurerm_public_ip.fad_a_pip.id
    primary                       = true
  }

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = azurerm_subnet.subnet_external.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fad_ipaddress_a["3"]
    public_ip_address_id          = azurerm_public_ip.fad_floating_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fad_a_ifc_ext_nsg" {
  network_interface_id      = azurerm_network_interface.fad_a_ifc_ext.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_network_interface" "fad_a_ifc_int" {
  name                 = "${var.PREFIX}-FAD-A-IFC-INT"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fad_ipaddress_a["2"]
  }
}

resource "azurerm_network_interface_security_group_association" "fad_a_ifc_int_nsg" {
  network_interface_id      = azurerm_network_interface.fad_a_ifc_int.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_virtual_machine" "fad_a_vm" {
  name                         = "${var.PREFIX}-FAD-A-VM"
  location                     = azurerm_resource_group.resourcegroup.location
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  network_interface_ids        = [azurerm_network_interface.fad_a_ifc_ext.id, azurerm_network_interface.fad_a_ifc_int.id]
  primary_network_interface_id = azurerm_network_interface.fad_a_ifc_ext.id
  vm_size                      = var.fad_vmsize
  availability_set_id          = azurerm_availability_set.fad_hub_avset.id

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortiadc"
    sku       = var.IMAGESKUFAD
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortiadc"
    name      = var.IMAGESKUFAD
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FAD-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FAD-A-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FAD-A-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
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

##############################################################################################################
# FortiADC B
##############################################################################################################

resource "azurerm_network_interface" "fad_b_ifc_ext" {
  name                 = "${var.PREFIX}-FAD-B-IFC-EXT"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_external.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fad_ipaddress_b["1"]
    public_ip_address_id          = azurerm_public_ip.fad_b_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fad_b_ifc_ext_nsg" {
  network_interface_id      = azurerm_network_interface.fad_b_ifc_ext.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_network_interface" "fad_b_ifc_int" {
  name                 = "${var.PREFIX}-FAD-B-IFC-INT"
  location             = azurerm_resource_group.resourcegroup.location
  resource_group_name  = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_internal.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fad_ipaddress_b["2"]
  }
}

resource "azurerm_network_interface_security_group_association" "fad_b_ifc_int_nsg" {
  network_interface_id      = azurerm_network_interface.fad_b_ifc_int.id
  network_security_group_id = azurerm_network_security_group.fad_nsg.id
}

resource "azurerm_virtual_machine" "fad_b_vm" {
  name                         = "${var.PREFIX}-FAD-B-VM"
  location                     = azurerm_resource_group.resourcegroup.location
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  network_interface_ids        = [azurerm_network_interface.fad_b_ifc_ext.id, azurerm_network_interface.fad_b_ifc_int.id]
  primary_network_interface_id = azurerm_network_interface.fad_b_ifc_ext.id
  vm_size                      = var.fad_vmsize
  availability_set_id          = azurerm_availability_set.fad_hub_avset.id

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortiadc"
    sku       = var.IMAGESKUFAD
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortiadc"
    name      = var.IMAGESKUFAD
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FAD-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FAD-B-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FAD-B-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
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

#data "azurerm_public_ip" "fad_floating_pip" {
#  name                = azurerm_public_ip.fad_floating_pip.name
#  resource_group_name = azurerm_resource_group.resourcegroup.name
#}

#data "azurerm_public_ip" "fad_a_pip" {
#  name                = azurerm_public_ip.fad_a_pip.name
#  resource_group_name = azurerm_resource_group.resourcegroup.name
#}

#data "azurerm_public_ip" "fad_b_pip" {
#  name                = azurerm_public_ip.fad_b_pip.name
#  resource_group_name = azurerm_resource_group.resourcegroup.name
#}

