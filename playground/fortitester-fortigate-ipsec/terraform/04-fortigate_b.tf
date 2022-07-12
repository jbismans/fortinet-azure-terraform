##############################################################################################################
#
# Fortitester IPsec throughput
#
##############################################################################################################

resource "azurerm_public_ip" "fgt_b_pip" {
  name                         = "${var.PREFIX}-FGT-B-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-b-pip")}"
}

resource "azurerm_network_interface" "fgt_b_ifc_transit" {
  name                      = "${var.PREFIX}-FGT-B-IFC-TRANSIT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"
  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.transit_subnet.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_b_ipaddress["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_b_pip.id}"
  }
}

resource "azurerm_network_interface" "fgt_b_ifc_lan" {
  name                      = "${var.PREFIX}-FGT-B-IFC-LAN"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.lan_b_subnet.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_b_ipaddress["2"]}"
  }
}

resource "azurerm_virtual_machine" "fgt_b_vm" {
  name                  = "${var.PREFIX}-FGT-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_b_ifc_transit.id}", "${azurerm_network_interface.fgt_b_ifc_lan.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fgt_b_ifc_transit.id}"
  vm_size               = "${var.fgt_b_vmsize}"

  identity {
    type      = "SystemAssigned"
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
    name              = "${var.PREFIX}-FGT-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FGT-B-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FGT-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_b_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    vendor = "Fortinet"
  }
}

data "template_file" "fgt_b_custom_data" {
  template = "${file("${path.module}/customdata-fgt-b.tpl")}"

  vars = {
    fgt_b_vm_name = "${var.PREFIX}-FGT-B"
    fgt_b_license_file = "${var.FGT_LICENSE_FILE_B}"
    fgt_b_username = "${var.USERNAME}"
    fgt_b_transit_ipaddr = "${var.fgt_b_ipaddress["1"]}"
    fgt_b_transit_mask = "${var.subnetmask["1"]}"
    fgt_b_transit_gw =  "${var.gateway_ipaddress["1"]}"
    fgt_b_lan_ipaddr = "${var.fgt_b_ipaddress["2"]}"
    fgt_b_lan_mask = "${var.subnetmask["2"]}"
    fgt_b_lan_gw =  "${var.gateway_ipaddress["2"]}"
  }
}

data "azurerm_public_ip" "fgt_b_pip" {
  name                = "${azurerm_public_ip.fgt_b_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}