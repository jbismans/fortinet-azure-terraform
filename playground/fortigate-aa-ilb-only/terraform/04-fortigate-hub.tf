##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

resource "azurerm_availability_set" "fgt_hub_avset" {
  name                = "${var.PREFIX}-HUB-FGT-AVSET"
  location            = "${var.LOCATION}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_group" "fgt_nsg" {
  name                = "${var.PREFIX}-FGT-NSG"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_rule" "fgt_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fgt_nsg.name}"
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
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fgt_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_lb" "ilb_hub" {
  name                = "${var.PREFIX}-HUB-ILB"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.PREFIX}-HUB-ILB-IP"
    subnet_id                     = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address            = "${var.ilb_internal_ipaddress_hub}"
    private_ip_address_allocation = "Static"
  }
}

resource "azurerm_lb_backend_address_pool" "ilb_hub_backend" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.ilb_hub.id}"
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "ilb_hub_probe" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.ilb_hub.id}"
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_rule" "ilb_haports_rule" {
  resource_group_name             = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                 = "${azurerm_lb.ilb_hub.id}"
  name                            = "ilb_haports_rule"
  protocol                        = "All"
  frontend_port                   = 0
  backend_port                    = 0
  frontend_ip_configuration_name  = "${var.PREFIX}-HUB-ILB-IP"
  probe_id                        = "${azurerm_lb_probe.ilb_hub_probe.id}"
  backend_address_pool_id         = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
  enable_floating_ip              = true
}

##############################################################################################################
# Fortigate A
##############################################################################################################
resource "azurerm_public_ip" "fgt_a_pip" {
  name                         = "${var.PREFIX}-FGT-A-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-a-pip")}"
}

resource "azurerm_network_interface" "fgt_hub_a_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-A-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_a_pip.id}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_a_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_a_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_hub_a_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_hub_a_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_hub_avset.id}"

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
    name              = "${var.PREFIX}-HUB-FGT-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-A-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-A-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_hub_a_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_hub_a_custom_data" {
  template = "${file("${path.module}/customdata-hub-a.tpl")}"

  vars = {
    fgt_hub_a_vm_name = "${var.PREFIX}-HUB-FGT-A"
    fgt_hub_a_license_file = "${var.FGT_LICENSE_FILE_HUB_A}"
    fgt_hub_a_ipaddr = "${var.fgt_hub_ipaddress["1"]}"
    fgt_hub_mask = "${var.subnetmask_hub["1"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["1"]}"
  }
}

##############################################################################################################
# Fortigate B
##############################################################################################################
resource "azurerm_public_ip" "fgt_b_pip" {
  name                         = "${var.PREFIX}-FGT-B-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-b-pip")}"
}

resource "azurerm_network_interface" "fgt_hub_b_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-B-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress["2"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_b_pip.id}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_b_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_b_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_hub_b_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_hub_b_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_hub_avset.id}"

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
    name              = "${var.PREFIX}-HUB-FGT-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-B-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_hub_b_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_hub_b_custom_data" {
  template = "${file("${path.module}/customdata-hub-b.tpl")}"

  vars = {
    fgt_hub_b_vm_name = "${var.PREFIX}-HUB-FGT-B"
    fgt_hub_b_license_file = "${var.FGT_LICENSE_FILE_HUB_B}"
    fgt_hub_b_ipaddr = "${var.fgt_hub_ipaddress["2"]}"
    fgt_hub_a_ipaddr = "${var.fgt_hub_ipaddress["1"]}"
    fgt_hub_mask = "${var.subnetmask_hub["1"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["1"]}"
  }
}

##############################################################################################################
# Fortigate C
##############################################################################################################
resource "azurerm_public_ip" "fgt_c_pip" {
  name                         = "${var.PREFIX}-FGT-C-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-c-pip")}"
}

resource "azurerm_network_interface" "fgt_hub_c_ifc" {
  name                      = "${var.PREFIX}-HUB-FGT-C-IFC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress["3"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_c_pip.id}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_c_ifc_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_c_ifc.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
}

resource "azurerm_virtual_machine" "fgt_hub_c_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-C-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_hub_c_ifc.id}"]
  vm_size               = "${var.fgt_vmsize_hub}"
  availability_set_id   = "${azurerm_availability_set.fgt_hub_avset.id}"

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
    name              = "${var.PREFIX}-HUB-FGT-C-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-HUB-FGT-C-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "50"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-HUB-FGT-C-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_hub_c_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
  }
}

data "template_file" "fgt_hub_c_custom_data" {
  template = "${file("${path.module}/customdata-hub-c.tpl")}"

  vars = {
    fgt_hub_c_vm_name = "${var.PREFIX}-HUB-FGT-C"
    fgt_hub_c_license_file = "${var.FGT_LICENSE_FILE_HUB_C}"
    fgt_hub_c_ipaddr = "${var.fgt_hub_ipaddress["3"]}"
    fgt_hub_a_ipaddr = "${var.fgt_hub_ipaddress["1"]}"
    fgt_hub_mask = "${var.subnetmask_hub["1"]}"
    fgt_hub_gw =  "${var.gateway_ipaddress_hub["1"]}"
  }
}