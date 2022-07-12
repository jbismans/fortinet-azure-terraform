##############################################################################################################
#
# Demo FortiGate loadbalanced Active/Passive
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

resource "azurerm_public_ip" "plb_hub_pip" {
  name                         = "${var.PREFIX}-HUB-PLB-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "plb-pip")}"
}

resource "azurerm_lb" "plb_hub" {
  name                = "${var.PREFIX}-HUB-PLB"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.PREFIX}-HUB-PLB-PIP"
    public_ip_address_id = "${azurerm_public_ip.plb_hub_pip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "plb_hub_backend" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.plb_hub.id}"
  name                = "BackEndPool"
}

resource "azurerm_lb_probe" "plb_hub_probe" {
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id     = "${azurerm_lb.plb_hub.id}"
  name                = "lbprobe"
  port                = 8008
}

resource "azurerm_lb_rule" "plb_hub_rule_fmfg" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_hub.id}"
  name                           = "PublicLBRule-PIP-fmfg"
  protocol                       = "Tcp"
  frontend_port                  = 541
  backend_port                   = 541
  frontend_ip_configuration_name = "${var.PREFIX}-HUB-PLB-PIP"
  probe_id                       = "${azurerm_lb_probe.plb_hub_probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "plb_hub_rule_ike" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_hub.id}"
  name                           = "PublicLBRule-PIP-ike-udp-500"
  protocol                       = "Udp"
  frontend_port                  = 500
  backend_port                   = 500
  frontend_ip_configuration_name = "${var.PREFIX}-HUB-PLB-PIP"
  probe_id                       = "${azurerm_lb_probe.plb_hub_probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_rule" "plb_hub_rule_ipsec" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_hub.id}"
  name                           = "PublicLBRule-PIP-ipsec-udp-4500"
  protocol                       = "Udp"
  frontend_port                  = 4500
  backend_port                   = 4500
  frontend_ip_configuration_name = "${var.PREFIX}-HUB-PLB-PIP"
  probe_id                       = "${azurerm_lb_probe.plb_hub_probe.id}"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
  enable_floating_ip             = false
  disable_outbound_snat          = true
}

resource "azurerm_lb_outbound_rule" "plb_outbound_rule" {
  resource_group_name            = "${azurerm_resource_group.resourcegroup.name}"
  loadbalancer_id                = "${azurerm_lb.plb_hub.id}"
  name                           = "OutboundRule"
  protocol                       = "All"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
  allocated_outbound_ports       = 31984
  frontend_ip_configuration {
    name = "${var.PREFIX}-HUB-PLB-PIP"
  }
}

resource "azurerm_lb" "ilb_hub" {
  name                = "${var.PREFIX}-HUB-ILB"
  location            = "${var.LOCATION}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.PREFIX}-HUB-ILB-IP"
    subnet_id                     = "${azurerm_subnet.subnet2_hub.id}"
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

resource "azurerm_storage_account" "bootdiag_storage" {
  name                     = "${lower(var.BOOTDIAG_STORAGE)}"
  resource_group_name      = "${azurerm_resource_group.resourcegroup.name}"
  location                 = "${var.LOCATION}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

##############################################################################################################
# Fortigate A
##############################################################################################################

resource "azurerm_network_interface" "fgt_hub_a_ifc_ext" {
  name                      = "${var.PREFIX}-HUB-FGT-A-IFC-EXT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_a["1"]}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt_a_ifc_ext_2_plb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_a_ifc_ext.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
}

resource "azurerm_network_interface" "fgt_hub_a_ifc_int" {
  name                      = "${var.PREFIX}-HUB-FGT-A-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_a["2"]}"
  }
}
resource "azurerm_network_interface_backend_address_pool_association" "fgt_a_ifc_int_2_ilb_hub_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_a_ifc_int.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
}


resource "azurerm_network_interface" "fgt_hub_a_ifc_hasync" {
  name                      = "${var.PREFIX}-HUB-FGT-A-IFC-HASYNC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_a["3"]}"
  }
}

resource "azurerm_public_ip" "fgt_hub_a_mgmt_pip" {
  name                         = "${var.PREFIX}-HUB-FGT-A-MGMT-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-a-mgmt-pip")}"
}

resource "azurerm_network_interface" "fgt_hub_a_ifc_mgmt" {
  name                      = "${var.PREFIX}-HUB-FGT-A-IFC-MGMT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet4_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_a["4"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_hub_a_mgmt_pip.id}"
  }
}

resource "azurerm_virtual_machine" "fgt_hub_a_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-A-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_hub_a_ifc_ext.id}", "${azurerm_network_interface.fgt_hub_a_ifc_int.id}", "${azurerm_network_interface.fgt_hub_a_ifc_hasync.id}", "${azurerm_network_interface.fgt_hub_a_ifc_mgmt.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fgt_hub_a_ifc_ext.id}"
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
    disk_size_gb      = "10"
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

  boot_diagnostics {
    enabled     = true
    storage_uri = "${format("%s%s%s", "https://", lower(var.BOOTDIAG_STORAGE), ".blob.core.windows.net/")}"
  }
   
  tags = {
  }
}

data "template_file" "fgt_hub_a_custom_data" {
  template = "${file("${path.module}/customdata-hub-a.tpl")}"

  vars = {
    fgt_hub_a_vm_name = "${var.PREFIX}-HUB-FGT-A"
    fgt_hub_a_license_file = "${var.FGT_LICENSE_FILE_HUB_A}"
    fgt_hub_a_username = "${var.USERNAME}"
    fgt_hub_a_external_ipaddr = "${var.fgt_hub_ipaddress_a["1"]}"
    fgt_hub_a_external_mask = "${var.subnetmask_hub["1"]}"
    fgt_hub_a_external_gw =  "${var.gateway_ipaddress_hub["1"]}"
    fgt_hub_a_internal_ipaddr = "${var.fgt_hub_ipaddress_a["2"]}"
    fgt_hub_a_internal_mask = "${var.subnetmask_hub["2"]}"
    fgt_hub_a_internal_gw =  "${var.gateway_ipaddress_hub["2"]}"
    fgt_hub_a_hasync_ipaddr = "${var.fgt_hub_ipaddress_a["3"]}"
    fgt_hub_a_hasync_mask = "${var.subnetmask_hub["3"]}"
    fgt_hub_a_hasync_gw =  "${var.gateway_ipaddress_hub["3"]}"
    fgt_hub_a_mgmt_ipaddr = "${var.fgt_hub_ipaddress_a["4"]}"
    fgt_hub_a_mgmt_mask = "${var.subnetmask_hub["4"]}"
    fgt_hub_a_mgmt_gw =  "${var.gateway_ipaddress_hub["4"]}"
    fgt_hub_a_ha_peerip = "${var.fgt_hub_ipaddress_b["3"]}"
    hub_protected_net = "${var.subnet_hub["5"]}"
    hub_vnet_network =  "${var.vnet_hub}"
    spoke1_vnet_network = "${var.vnet_spoke1}"
    spoke2_vnet_network = "${var.vnet_spoke2}"
  }
}

##############################################################################################################
# Fortigate B
##############################################################################################################

resource "azurerm_network_interface" "fgt_hub_b_ifc_ext" {
  name                      = "${var.PREFIX}-HUB-FGT-B-IFC-EXT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_b["1"]}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt_hub_b_ifc_ext_2_plb_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_b_ifc_ext.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.plb_hub_backend.id}"
}

resource "azurerm_network_interface" "fgt_hub_b_ifc_int" {
  name                      = "${var.PREFIX}-HUB-FGT-B-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_b["2"]}"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "fgt_hub_b_ifc_int_2_plb_backendpool" {
  network_interface_id    = "${azurerm_network_interface.fgt_hub_b_ifc_int.id}"
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = "${azurerm_lb_backend_address_pool.ilb_hub_backend.id}"
}

resource "azurerm_network_interface" "fgt_hub_b_ifc_hasync" {
  name                      = "${var.PREFIX}-HUB-FGT-B-IFC-HASYNC"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_b["3"]}"
  }
}

resource "azurerm_public_ip" "fgt_hub_b_mgmt_pip" {
  name                         = "${var.PREFIX}-HUB-FGT-B-MGMT-PIP"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "fgt-b-mgmt-pip")}"
}

resource "azurerm_network_interface" "fgt_hub_b_ifc_mgmt" {
  name                      = "${var.PREFIX}-HUB-FGT-B-IFC-MGMT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet4_hub.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_hub_ipaddress_b["4"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_hub_b_mgmt_pip.id}"
  }
}

resource "azurerm_virtual_machine" "fgt_hub_b_vm" {
  name                  = "${var.PREFIX}-HUB-FGT-B-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_hub_b_ifc_ext.id}", "${azurerm_network_interface.fgt_hub_b_ifc_int.id}", "${azurerm_network_interface.fgt_hub_b_ifc_hasync.id}", "${azurerm_network_interface.fgt_hub_b_ifc_mgmt.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fgt_hub_b_ifc_ext.id}"
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
    disk_size_gb      = "10"
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

  boot_diagnostics {
    enabled     = true
    storage_uri = "${format("%s%s%s", "https://", lower(var.BOOTDIAG_STORAGE), ".blob.core.windows.net/")}"
  }

  tags = {
  }
}

data "template_file" "fgt_hub_b_custom_data" {
  template = "${file("${path.module}/customdata-hub-b.tpl")}"

  vars = {
    fgt_hub_b_vm_name = "${var.PREFIX}-HUB-FGT-B"
    fgt_hub_b_license_file = "${var.FGT_LICENSE_FILE_HUB_B}"
    fgt_hub_b_username = "${var.USERNAME}"
    fgt_hub_b_external_ipaddr = "${var.fgt_hub_ipaddress_b["1"]}"
    fgt_hub_b_external_mask = "${var.subnetmask_hub["1"]}"
    fgt_hub_b_external_gw =  "${var.gateway_ipaddress_hub["1"]}"
    fgt_hub_b_internal_ipaddr = "${var.fgt_hub_ipaddress_b["2"]}"
    fgt_hub_b_internal_mask = "${var.subnetmask_hub["2"]}"
    fgt_hub_b_internal_gw =  "${var.gateway_ipaddress_hub["2"]}"
    fgt_hub_b_hasync_ipaddr = "${var.fgt_hub_ipaddress_b["3"]}"
    fgt_hub_b_hasync_mask = "${var.subnetmask_hub["3"]}"
    fgt_hub_b_hasync_gw =  "${var.gateway_ipaddress_hub["3"]}"
    fgt_hub_b_mgmt_ipaddr = "${var.fgt_hub_ipaddress_b["4"]}"
    fgt_hub_b_mgmt_mask = "${var.subnetmask_hub["4"]}"
    fgt_hub_b_mgmt_gw =  "${var.gateway_ipaddress_hub["4"]}"
    fgt_hub_b_ha_peerip = "${var.fgt_hub_ipaddress_a["3"]}"
    hub_protected_net = "${var.subnet_hub["5"]}"
    hub_vnet_network =  "${var.vnet_hub}"
    spoke1_vnet_network = "${var.vnet_spoke1}"
    spoke2_vnet_network = "${var.vnet_spoke2}"
  }
}

data "azurerm_public_ip" "fgt_hub_a_mgmt_pip" {
  name                = "${azurerm_public_ip.fgt_hub_a_mgmt_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fgt_hub_b_mgmt_pip" {
  name                = "${azurerm_public_ip.fgt_hub_b_mgmt_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "plb_hub_pip" {
  name                = "${azurerm_public_ip.plb_hub_pip.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}