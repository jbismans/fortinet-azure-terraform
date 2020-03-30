##############################################################################################################
#
# Fortitester internal throughput
#
##############################################################################################################

resource "azurerm_public_ip" "fts_pip" {
  name                = "${var.PREFIX}-FTS-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "fts-pip")
}

resource "azurerm_network_interface" "fts_ifc_port1" {
  name                          = "${var.PREFIX}-FTS-IFC-PORT1"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.port1_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fts_ipaddress["1"]
  }
}

resource "azurerm_network_interface_security_group_association" "fts_ifc_port1_nsg" {
  network_interface_id      = azurerm_network_interface.fts_ifc_port1.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_network_interface" "fts_ifc_port2" {
  name                          = "${var.PREFIX}-FTS-IFC-PORT2"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.port2_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fts_ipaddress["2"]
  }
}

resource "azurerm_network_interface_security_group_association" "fts_ifc_port2_nsg" {
  network_interface_id      = azurerm_network_interface.fts_ifc_port2.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_network_interface" "fts_ifc_mgmt" {
  name                          = "${var.PREFIX}-FTS-IFC-MGMT"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.mgmt_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fts_ipaddress["3"]
    public_ip_address_id          = azurerm_public_ip.fts_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fts_ifc_mgmt_nsg" {
  network_interface_id      = azurerm_network_interface.fts_ifc_mgmt.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_virtual_machine" "fts_vm" {
  name                         = "${var.PREFIX}-FTS-VM"
  location                     = azurerm_resource_group.resourcegroup.location
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  network_interface_ids        = [azurerm_network_interface.fts_ifc_port1.id, azurerm_network_interface.fts_ifc_port2.id, azurerm_network_interface.fts_ifc_mgmt.id]
  primary_network_interface_id = azurerm_network_interface.fts_ifc_mgmt.id
  vm_size                      = var.fts_size

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortitester"
    sku       = "fts-vm-byol"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortitester"
    name      = "fts-vm-byol"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FTS-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FTS-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FTS-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    vendor = "Fortinet"
  }
}

data "azurerm_public_ip" "fts_pip" {
  name                = azurerm_public_ip.fts_pip.name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

