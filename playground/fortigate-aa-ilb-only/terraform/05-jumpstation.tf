##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

##############################################################################################################
# Jumpstation
##############################################################################################################
resource "azurerm_public_ip" "jumpstation_pip" {
  name                         = "${var.PREFIX}-JUMPSTATION-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "jumpstation-pip")}"
}

resource "azurerm_network_security_group" "jumpstation_nsg" {
  name                = "${var.PREFIX}-JUMPSTATION-NSG"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_rule" "jumpstation_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.jumpstation_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "jumpstation_rdp_in" {
  name                        = "RDPInbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.jumpstation_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface" "jumpstation_ifc" {
  name                            = "${var.PREFIX}-JUMPSTATION-IFC"
  location                        = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name             = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding            = false
  network_security_group_id       = "${azurerm_network_security_group.jumpstation_nsg.id}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.jumpstation_hub.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "${var.jumpstation_ipaddress["1"]}"
    public_ip_address_id          = "${azurerm_public_ip.jumpstation_pip.id}"
  }
}

resource "azurerm_virtual_machine" "jumpstation_vm" {
  name                  = "${var.PREFIX}-JUMPSTATION-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.jumpstation_ifc.id}"]
  vm_size               = "${var.jumpstation_vmsize}"

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
  }
}

data "azurerm_public_ip" "jumpstation_pip" {
  name                = "${azurerm_public_ip.jumpstation_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}