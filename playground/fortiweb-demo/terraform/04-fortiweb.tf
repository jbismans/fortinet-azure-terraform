##############################################################################################################
#
# FortiWeb Azure Demo
#
##############################################################################################################

resource "azurerm_availability_set" "fwb_hub_avset" {
  name                = "${var.PREFIX}-HUB-FWB-AVSET"
  location            = "${var.LOCATION}"
  managed             = true
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_group" "fwb_nsg" {
  name                = "${var.PREFIX}-FWB-NSG"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

resource "azurerm_network_security_rule" "fwb_nsg_allowallout" {
  name                        = "AllowAllOutbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fwb_nsg.name}"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "fwb_nsg_allowallin" {
  name                        = "AllowAllInbound"
  resource_group_name         = "${azurerm_resource_group.resourcegroup.name}"
  network_security_group_name = "${azurerm_network_security_group.fwb_nsg.name}"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "plb_fwb_pip" {
  name                         = "${var.PREFIX}-FWB-PLB-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "plb-pip")}"
}

resource "azurerm_public_ip" "fwb_a_pip" {
  name                         = "${var.PREFIX}-FWB-A-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fwb-a-pip")}"
}

resource "azurerm_public_ip" "fwb_b_pip" {
  name                         = "${var.PREFIX}-FWB-B-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fwb-b-pip")}"
}

resource "azurerm_lb" "plb_fwb" {
  name                = "${var.PREFIX}-FWB-PLB"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.PREFIX}-FWB-PLB-PIP"
    public_ip_address_id = "${azurerm_public_ip.plb_fwb_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "plb_fwb_backend" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.plb_fwb.id}"
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "plb_fwb_probe" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.plb_fwb.id}"
  name                = "lbprobe"
  port                = 8443
}

resource "azurerm_lb_rule" "plb_fwb_http_rule" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_fwb.id}"
  name                           = "PublicLBRule-PIP-HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "${var.PREFIX}-FWB-PLB-PIP"
  probe_id                       = "${azurerm_lb_probe.plb_fwb_probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_fwb_backend.id}"
  enable_floating_ip             = true
}

resource "azurerm_lb_rule" "plb_fwb_https_rule" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_fwb.id}"
  name                           = "PublicLBRule-PIP-HTTPS"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "${var.PREFIX}-FWB-PLB-PIP"
  probe_id                       = "${azurerm_lb_probe.plb_fwb_probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_fwb_backend.id}"
  enable_floating_ip             = true
}

resource "azurerm_storage_account" "bootdiag_storage" {
  name                     = "${lower(var.BOOTDIAG_STORAGE)}"
  resource_group_name      = "${azurerm_resource_group.resourcegroup.name}"
  location                 = "${var.LOCATION}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

##############################################################################################################
# FortiWeb A
##############################################################################################################

resource "azurerm_network_interface" "fwb_a_ifc_ext" {
  name                      = "${var.PREFIX}-FWB-A-IFC-EXT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  network_security_group_id = "${azurerm_network_security_group.fwb_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet_external.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fwb_ipaddress_a["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fwb_a_pip.id}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "fwb_a_ifc_ext_2_plb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fwb_a_ifc_ext.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plb_fwb_backend.id}"
}

resource "azurerm_network_interface" "fwb_a_ifc_int" {
  name                      = "${var.PREFIX}-FWB-A-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  network_security_group_id = "${azurerm_network_security_group.fwb_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet_internal.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fwb_ipaddress_a["2"]}"
  }
}

resource "azurerm_virtual_machine" "fwb_a_vm" {
  name                  = "${var.PREFIX}-FWB-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fwb_a_ifc_ext.id}", "${azurerm_network_interface.fwb_a_ifc_int.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fwb_a_ifc_ext.id}"
  vm_size               = "${var.fwb_vmsize}"
  availability_set_id   = "${azurerm_availability_set.fwb_hub_avset.id}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortiweb-vm_v5"
    sku       = "${var.IMAGESKUFWB}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortiweb-vm_v5"
    name      = "${var.IMAGESKUFWB}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FWB-A-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FWB-A-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FWB-A-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
#    custom_data    = "${data.template_file.fwb_a_custom_data.rendered}"
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

#data "template_file" "fwb_a_custom_data" {
#  template = "${file("${path.module}/customdata-fwb-a.tpl")}"
#
#  vars = {
#    fwb_a_vm_name = "${var.PREFIX}-FWB-A"
#    fwb_a_license_file = "${var.FWB_LICENSE_FILE_A}"
#    fwb_a_external_gw =  "${var.gateway_ipaddress["1"]}"
#    fwb_a_internal_gw =  "${var.gateway_ipaddress["2"]}"
#    fwb_a_internal_ipaddr = "${var.fwb_ipaddress_a["2"]}"
#    fwb_a_ha_peerip = "${var.fwb_ipaddress_b["2"]}"
#    vnet_network =  "${var.vnet}"
#  }
#}

##############################################################################################################
# FortiWeb B
##############################################################################################################

resource "azurerm_network_interface" "fwb_b_ifc_ext" {
  name                      = "${var.PREFIX}-FWB-B-IFC-EXT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  network_security_group_id = "${azurerm_network_security_group.fwb_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet_external.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fwb_ipaddress_b["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fwb_b_pip.id}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "fwb_b_ifc_ext_2_plb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fwb_b_ifc_ext.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plb_fwb_backend.id}"
}

resource "azurerm_network_interface" "fwb_b_ifc_int" {
  name                      = "${var.PREFIX}-FWB-B-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  network_security_group_id = "${azurerm_network_security_group.fwb_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet_internal.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fwb_ipaddress_b["2"]}"
  }
}

resource "azurerm_virtual_machine" "fwb_b_vm" {
  name                  = "${var.PREFIX}-FWB-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fwb_b_ifc_ext.id}", "${azurerm_network_interface.fwb_b_ifc_int.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fwb_b_ifc_ext.id}"
  vm_size               = "${var.fwb_vmsize}"
  availability_set_id   = "${azurerm_availability_set.fwb_hub_avset.id}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortiweb-vm_v5"
    sku       = "${var.IMAGESKUFWB}"
    version   = "latest"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortiweb-vm_v5"
    name      = "${var.IMAGESKUFWB}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-FWB-B-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-FWB-B-DATADISK"
    managed_disk_type = "Premium_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "10"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-FWB-B-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
#    custom_data    = "${data.template_file.fwb_b_custom_data.rendered}"
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

#data "template_file" "fwb_b_custom_data" {
#  template = "${file("${path.module}/customdata-fwb-b.tpl")}"
#
#  vars = {
#    fwb_b_vm_name = "${var.PREFIX}-FWB-B"
#    fwb_b_license_file = "${var.FWB_LICENSE_FILE_B}"
#    fwb_b_external_gw =  "${var.gateway_ipaddress["1"]}"
#    fwb_b_internal_gw =  "${var.gateway_ipaddress["2"]}"
#    fwb_b_internal_ipaddr = "${var.fwb_ipaddress_b["2"]}"
#    fwb_b_ha_peerip = "${var.fwb_ipaddress_a["2"]}"
#    vnet_network =  "${var.vnet}"
#  }
#}


data "azurerm_public_ip" "plb_fwb_pip" {
  name                = "${azurerm_public_ip.plb_fwb_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fwb_a_pip" {
  name                = "${azurerm_public_ip.fwb_a_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fwb_b_pip" {
  name                = "${azurerm_public_ip.fwb_b_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}