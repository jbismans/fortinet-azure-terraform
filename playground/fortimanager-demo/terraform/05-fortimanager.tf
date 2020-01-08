##############################################################################################################
#
# Demo FortiManager
#
##############################################################################################################

resource "azurerm_public_ip" "fmg_pip" {
  name                         = "${var.PREFIX}-FMG-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fmg-pip")}"
}

resource "azurerm_network_security_group" "fmg_nsg" {
  name                = "${var.PREFIX}-FMG-NSG"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_rule" "fmg_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fmg_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fmg_nsg_allowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fmg_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_storage_account" "bootdiag_storage" {
  name                     = "jbidemofmgsa"
  resource_group_name      = "${azurerm_resource_group.resourcegroup.name}"
  location                 = "${var.LOCATION}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_network_interface" "fmg_ifc" {
  name                      = "${var.PREFIX}-FMG-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = false
  enable_accelerated_networking   = false
  network_security_group_id = "${azurerm_network_security_group.fmg_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_fmg.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fmg_ipaddress["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fmg_pip.id}"
  }
}

resource "azurerm_virtual_machine" "fmg_vm" {
  name                  = "${var.PREFIX}-FMG-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fmg_ifc.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fmg_ifc.id}"
  vm_size               = "${var.fmg_vmsize}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet-fortimanager"
    sku       = "${var.IMAGESKUFMG}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet-fortimanager"
    name      = "${var.IMAGESKUFMG}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FMG-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FMG-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FMG-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${format("%s%s%s", "https://", lower(var.BOOTDIAG_STORAGE), ".blob.core.windows.net/")}"
  }

  tags = {
  }
}

data "azurerm_public_ip" "fmg_pip" {
  name                = "${azurerm_public_ip.fmg_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}