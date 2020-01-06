##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_availability_set" "fgt_int_hub_avset" {
  name                = "${var.PREFIX}-HUB-FGT-INT-AVSET"
  location            = "${var.LOCATION}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_group" "fgt_int_nsg" {
  name                = "${var.PREFIX}-FGT-INT-NSG"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_rule" "fgt_int_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fgt_int_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fgt_int_nsg_allowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fgt_int_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_lb" "fgt_int_ilb_hub" {
  name                = "${var.PREFIX}-HUB-FGT-INT-ILB"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.PREFIX}-HUB-FGT-INT-ILB-IP"
    subnet_id                     = "${azurerm_subnet.fgt_int_hub.id}"
    private_ip_address            = "${var.ilb_int_fgt_ipaddress_hub}"
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "fgt_int_ilb_hub_backend" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.fgt_int_ilb_hub.id}"
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "fgt_int_ilb_hub_probe" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.fgt_int_ilb_hub.id}"
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_rule" "fgt_int_ilb_haports_rule" {
  resource_group_name             = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                 = "${azurerm_lb.fgt_int_ilb_hub.id}"
  name                            = "ilb_haports_rule"
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  frontend_ip_configuration_name  = "${var.PREFIX}-HUB-FGT-INT-ILB-IP"
  probe_id                        = "${azurerm_lb_probe.fgt_int_ilb_hub_probe.id}"
  backend_address_pool_id         = "${azurerm_lb_backend_address_pool.fgt_int_ilb_hub_backend.id}"
  enable_floating_ip              = true
}

##############################################################################################################
# Fortigate A
##############################################################################################################
resource "azurerm_network_interface" "fgt_int_hub_a_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-INT-A-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_int_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.fgt_int_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_int_hub_ipaddress["A"]}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_int_a_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_int_hub_a_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.fgt_int_ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_int_hub_a_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-INT-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_int_hub_a_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_int_hub_avset.id}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "${var.IMAGESKUFGT}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "${var.IMAGESKUFGT}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-A-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-INT-A-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_int_hub_a_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_int_hub_a_custom_data" {
  template = "${file("${path.module}/customdata-hub-int-a.tpl")}"

  vars = {
    fgt_hub_a_vm_name = "${var.PREFIX}-HUB-FGT-INT-A"
    fgt_hub_a_license_file = "${var.FGT_LICENSE_FILE_HUB_INT_A}"
    fgt_hub_a_ipaddr = "${var.fgt_int_hub_ipaddress["A"]}"
    fgt_hub_mask = "${var.subnetmask_hub["fgt_int"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["fgt_int"]}"
  }
}

##############################################################################################################
# Fortigate B
##############################################################################################################
resource "azurerm_network_interface" "fgt_int_hub_b_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-INT-B-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_int_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.fgt_int_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_int_hub_ipaddress["B"]}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_int_b_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_int_hub_b_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.fgt_int_ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_int_hub_b_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-INT-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_int_hub_b_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_int_hub_avset.id}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "${var.IMAGESKUFGT}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "${var.IMAGESKUFGT}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-B-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-INT-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_int_hub_b_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_int_hub_b_custom_data" {
  template = "${file("${path.module}/customdata-hub-int-b.tpl")}"

  vars = {
    fgt_hub_b_vm_name = "${var.PREFIX}-HUB-FGT-INT-B"
    fgt_hub_b_license_file = "${var.FGT_LICENSE_FILE_HUB_INT_B}"
    fgt_hub_b_ipaddr = "${var.fgt_int_hub_ipaddress["B"]}"
    fgt_hub_a_ipaddr = "${var.fgt_int_hub_ipaddress["A"]}"
    fgt_hub_mask = "${var.subnetmask_hub["fgt_int"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["fgt_int"]}"
  }
}

##############################################################################################################
# Fortigate C
##############################################################################################################
resource "azurerm_network_interface" "fgt_int_hub_c_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-INT-C-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_int_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.fgt_int_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_int_hub_ipaddress["C"]}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_int_c_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_int_hub_c_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.fgt_int_ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_int_hub_c_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-INT-C-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_int_hub_c_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_int_hub_avset.id}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "${var.IMAGESKUFGT}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "${var.IMAGESKUFGT}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-C-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-INT-C-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-INT-C-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_int_hub_c_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_int_hub_c_custom_data" {
  template = "${file("${path.module}/customdata-hub-int-c.tpl")}"

  vars = {
    fgt_hub_c_vm_name = "${var.PREFIX}-HUB-FGT-INT-C"
    fgt_hub_c_license_file = "${var.FGT_LICENSE_FILE_HUB_INT_C}"
    fgt_hub_c_ipaddr = "${var.fgt_int_hub_ipaddress["C"]}"
    fgt_hub_a_ipaddr = "${var.fgt_int_hub_ipaddress["A"]}"
    fgt_hub_mask = "${var.subnetmask_hub["fgt_int"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["fgt_int"]}"
  }
}