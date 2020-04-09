##############################################################################################################
#
# Fortitester internal throughput
#
##############################################################################################################

resource "azurerm_public_ip" "fgt_pip" {
  name                = "${var.PREFIX}-FGT-PIP"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = format("%s-%s", lower(var.PREFIX), "fgt-pip")
}

resource "azurerm_network_security_group" "fgt_nsg" {
  name                = "${var.PREFIX}-FGT-NSG"
  location            = var.LOCATION
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

resource "azurerm_network_security_rule" "fgt_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fgt_nsg.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fgt_nsg_allowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = azurerm_resource_group.resourcegroup.name
  network_security_group_name = azurerm_network_security_group.fgt_nsg.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface" "fgt_ifc_port1" {
  name                          = "${var.PREFIX}-FGT-IFC-PORT1"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.port1_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fgt_ipaddress["1"]
    public_ip_address_id          = azurerm_public_ip.fgt_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "fgt_ifc_port1_nsg" {
  network_interface_id      = azurerm_network_interface.fgt_ifc_port1.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_network_interface" "fgt_ifc_port2" {
  name                          = "${var.PREFIX}-FGT-IFC-PORT2"
  location                      = azurerm_resource_group.resourcegroup.location
  resource_group_name           = azurerm_resource_group.resourcegroup.name
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.port2_subnet.id
    private_ip_address_allocation = "static"
    private_ip_address            = var.fgt_ipaddress["2"]
  }
}

resource "azurerm_network_interface_security_group_association" "fgt_ifc_port2_nsg" {
  network_interface_id      = azurerm_network_interface.fgt_ifc_port2.id
  network_security_group_id = azurerm_network_security_group.fgt_nsg.id
}

resource "azurerm_virtual_machine" "fgt_vm" {
  name                         = "${var.PREFIX}-FGT-VM"
  location                     = azurerm_resource_group.resourcegroup.location
  resource_group_name          = azurerm_resource_group.resourcegroup.name
  network_interface_ids        = [azurerm_network_interface.fgt_ifc_port1.id, azurerm_network_interface.fgt_ifc_port2.id]
  primary_network_interface_id = azurerm_network_interface.fgt_ifc_port1.id
  vm_size                      = var.fgt_vmsize

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "fortinet_fg-vm"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FGT-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FGT-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FGT-VM"
    admin_username = var.USERNAME
    admin_password = var.PASSWORD
    custom_data    = data.template_file.fgt_custom_data.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    vendor = "Fortinet"
  }
}

data "template_file" "fgt_custom_data" {
  template = file("${path.module}/customdata-fgt.tpl")

  vars = {
    fgt_vm_name      = "${var.PREFIX}-FGT"
    fgt_license_file = var.FGT_LICENSE_FILE
    fgt_username     = var.USERNAME
    fgt_port1_ipaddr = var.fgt_ipaddress["1"]
    fgt_port1_mask   = var.subnetmask["1"]
    fgt_port1_gw     = var.gateway_ipaddress["1"]
    fgt_port2_ipaddr = var.fgt_ipaddress["2"]
    fgt_port2_mask   = var.subnetmask["2"]
    fgt_port2_gw     = var.gateway_ipaddress["2"]
    subnet_mgmt      = var.subnet["3"]
    fts_mgmt_ipaddr  = var.fts_ipaddress["3"]
  }
}

data "azurerm_public_ip" "fgt_pip" {
  name                = azurerm_public_ip.fgt_pip.name
  resource_group_name = azurerm_resource_group.resourcegroup.name
}

