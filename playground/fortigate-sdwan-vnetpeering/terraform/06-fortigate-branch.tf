###############################################################################################################
#
# FortiGate SD-WAN deployment
#
##############################################################################################################

##############################################################################################################
# BRANCH 1
##############################################################################################################
resource "azurerm_public_ip" "fgt_branch1_pip1" {
  name                         = "${var.PREFIX}-BRANCH1-FGT-PIP1"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "branch1-fgt-pip1")}"
}

resource "azurerm_public_ip" "fgt_branch1_pip2" {
  name                         = "${var.PREFIX}-BRANCH1-FGT-PIP2"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "branch1-fgt-pip2")}"
}

resource "azurerm_network_interface" "fgt_branch1_ifc_ext1" {
  name                      = "${var.PREFIX}-BRANCH1-FGT-IFC-EXT1"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"   #NSG is made in Hub template

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_branch1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch1["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_branch1_pip1.id}"
  }
}

resource "azurerm_network_interface" "fgt_branch1_ifc_ext2" {
  name                      = "${var.PREFIX}-BRANCH1-FGT-IFC-EXT2"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2_branch1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch1["2"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_branch1_pip2.id}"
  }
}

resource "azurerm_network_interface" "fgt_branch1_ifc_int" {
  name                      = "${var.PREFIX}-BRANCH1-FGT-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3_branch1.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch1["3"]}"
  }
}

resource "azurerm_virtual_machine" "fgt_branch1_vm" {
  name                  = "${var.PREFIX}-BRANCH1-FGT-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_branch1_ifc_ext1.id}", "${azurerm_network_interface.fgt_branch1_ifc_ext2.id}", "${azurerm_network_interface.fgt_branch1_ifc_int.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fgt_branch1_ifc_ext1.id}"
  vm_size               = "${var.fgt_vmsize_branch1}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "${var.IMAGESKUFGT}"
    version   = "latest"
    #version   = "6.0.6"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "${var.IMAGESKUFGT}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-BRANCH1-FGT-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-BRANCH1-FGT-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-BRANCH1-FGT-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_branch1_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FortiGate-SDWAN"
    vendor = "Fortinet"
  }
}

data "template_file" "fgt_branch1_custom_data" {
  template = "${file("${path.module}/customdata-branch1.tpl")}"

  vars = {
    fgt_branch1_vm_name = "${var.PREFIX}-BRANCH1-FGT"
    fgt_branch1_license_file = "${var.FGT_LICENSE_FILE_BRANCH1}"
    fgt_branch1_username = "${var.USERNAME}"
    fgt_branch1_external1_ipaddr = "${var.fgt_ipaddress_branch1["1"]}"
    fgt_branch1_external1_mask = "${var.subnetmask_branch1["1"]}"
    fgt_branch1_external1_gw =  "${var.gateway_ipaddress_branch1["1"]}"
    fgt_branch1_external2_ipaddr = "${var.fgt_ipaddress_branch1["2"]}"
    fgt_branch1_external2_mask = "${var.subnetmask_branch1["2"]}"
    fgt_branch1_external2_gw =  "${var.gateway_ipaddress_branch1["2"]}"
    fgt_branch1_internal_ipaddr = "${var.fgt_ipaddress_branch1["3"]}"
    fgt_branch1_internal_mask = "${var.subnetmask_branch1["3"]}"
    fgt_branch1_internal_gw =  "${var.gateway_ipaddress_branch1["3"]}"
    fgt_branch1_protected_net = "${var.subnet_branch1["5"]}"
    fgt_branch1_vnet_network =  "${var.vnet_branch1}"
    fmg_pip = "${data.azurerm_public_ip.fmg_pip.ip_address}"
  }
}

##############################################################################################################
# BRANCH 2
##############################################################################################################
resource "azurerm_public_ip" "fgt_branch2_pip1" {
  name                         = "${var.PREFIX}-BRANCH2-FGT-PIP1"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "branch2-fgt-pip1")}"
}

resource "azurerm_public_ip" "fgt_branch2_pip2" {
  name                         = "${var.PREFIX}-BRANCH2-FGT-PIP2"
  location                     = "${var.LOCATION}"
  resource_group_name          = "${azurerm_resource_group.resourcegroup.name}"
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${format("%s-%s", lower(var.PREFIX), "branch2-fgt-pip2")}"
}

resource "azurerm_network_interface" "fgt_branch2_ifc_ext1" {
  name                      = "${var.PREFIX}-BRANCH2-FGT-IFC-EXT1"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"   #NSG is made in Hub template

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet1_branch2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch2["1"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_branch2_pip1.id}"
  }
}

resource "azurerm_network_interface" "fgt_branch2_ifc_ext2" {
  name                      = "${var.PREFIX}-BRANCH2-FGT-IFC-EXT2"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"

  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet2_branch2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch2["2"]}"
    public_ip_address_id                    = "${azurerm_public_ip.fgt_branch2_pip2.id}"
  }
}

resource "azurerm_network_interface" "fgt_branch2_ifc_int" {
  name                      = "${var.PREFIX}-BRANCH2-FGT-IFC-INT"
  location                  = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name       = "${azurerm_resource_group.resourcegroup.name}"
  enable_ip_forwarding      = true
  enable_accelerated_networking   = true
  network_security_group_id = "${azurerm_network_security_group.fgt_nsg.id}"


  ip_configuration {
    name                                    = "ipconfig1"
    subnet_id                               = "${azurerm_subnet.subnet3_branch2.id}"
    private_ip_address_allocation           = "static"
    private_ip_address                      = "${var.fgt_ipaddress_branch2["3"]}"
  }
}

resource "azurerm_virtual_machine" "fgt_branch2_vm" {
  name                  = "${var.PREFIX}-BRANCH2-FGT-VM"
  location              = "${azurerm_resource_group.resourcegroup.location}"
  resource_group_name   = "${azurerm_resource_group.resourcegroup.name}"
  network_interface_ids = ["${azurerm_network_interface.fgt_branch2_ifc_ext1.id}", "${azurerm_network_interface.fgt_branch2_ifc_ext2.id}", "${azurerm_network_interface.fgt_branch2_ifc_int.id}"]
  primary_network_interface_id = "${azurerm_network_interface.fgt_branch2_ifc_ext1.id}"
  vm_size               = "${var.fgt_vmsize_branch2}"

  identity {
    type      = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "${var.IMAGESKUFGT}"
    version   = "latest"
    #version   = "6.0.6"
  }

  plan {
    publisher = "fortinet"
    product   = "fortinet_fortigate-vm_v5"
    name      = "${var.IMAGESKUFGT}"
  }

  storage_os_disk {
    name              = "${var.PREFIX}-BRANCH2-FGT-OSDISK"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name              = "${var.PREFIX}-BRANCH2-FGT-DATADISK"
    managed_disk_type = "Standard_LRS"
    create_option     = "Empty"
    lun               = 0
    disk_size_gb      = "30"
  }

  os_profile {
    computer_name  = "${var.PREFIX}-BRANCH2-FGT-VM"
    admin_username = "${var.USERNAME}"
    admin_password = "${var.PASSWORD}"
    custom_data    = "${data.template_file.fgt_branch2_custom_data.rendered}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "FortiGate-SDWAN"
    vendor = "Fortinet"
  }
}

data "template_file" "fgt_branch2_custom_data" {
  template = "${file("${path.module}/customdata-branch2.tpl")}"

  vars = {
    fgt_branch2_vm_name = "${var.PREFIX}-BRANCH2-FGT"
    fgt_branch2_license_file = "${var.FGT_LICENSE_FILE_BRANCH2}"
    fgt_branch2_username = "${var.USERNAME}"
    fgt_branch2_external1_ipaddr = "${var.fgt_ipaddress_branch2["1"]}"
    fgt_branch2_external1_mask = "${var.subnetmask_branch2["1"]}"
    fgt_branch2_external1_gw =  "${var.gateway_ipaddress_branch2["1"]}"
    fgt_branch2_external2_ipaddr = "${var.fgt_ipaddress_branch2["2"]}"
    fgt_branch2_external2_mask = "${var.subnetmask_branch2["2"]}"
    fgt_branch2_external2_gw =  "${var.gateway_ipaddress_branch2["2"]}"
    fgt_branch2_internal_ipaddr = "${var.fgt_ipaddress_branch2["3"]}"
    fgt_branch2_internal_mask = "${var.subnetmask_branch2["3"]}"
    fgt_branch2_internal_gw =  "${var.gateway_ipaddress_branch2["3"]}"
    fgt_branch2_protected_net = "${var.subnet_branch2["5"]}"
    fgt_branch2_vnet_network =  "${var.vnet_branch2}"
    fmg_pip = "${data.azurerm_public_ip.fmg_pip.ip_address}"
  }
}

data "azurerm_public_ip" "fgt_branch1_pip1" {
  name                = "${azurerm_public_ip.fgt_branch1_pip1.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fgt_branch1_pip2" {
  name                = "${azurerm_public_ip.fgt_branch1_pip2.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fgt_branch2_pip1" {
 name                = "${azurerm_public_ip.fgt_branch2_pip1.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

data "azurerm_public_ip" "fgt_branch2_pip2" {
  name                = "${azurerm_public_ip.fgt_branch2_pip2.name}"
  resource_group_name = "${azurerm_resource_group.resourcegroup.name}"
}

#output "fgt_branch1_pip2" {
#  value = "${data.azurerm_public_ip.fgt_hub_b_mgmt_pip.ip_address}"
#}
#
#output "fgt_branch2_pip1" {
#  value = "${data.azurerm_public_ip.fgt_hub_a_mgmt_pip.ip_address}"
#}
#
#output "fgt_branch2_pip2" {
#  value = "${data.azurerm_public_ip.fgt_hub_b_mgmt_pip.ip_address}"
#}