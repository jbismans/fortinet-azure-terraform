##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    plb_ipaddress = "${data.azurerm_public_ip.plb_hub_pip.ip_address}"
    fgt_hub_a_private_ip_address_ext = "${azurerm_network_interface.fgt_hub_a_ifc_ext.private_ip_address}"
    fgt_hub_a_private_ip_address_int = "${azurerm_network_interface.fgt_hub_a_ifc_int.private_ip_address}"
    fgt_hub_a_private_ip_address_hasync = "${azurerm_network_interface.fgt_hub_a_ifc_hasync.private_ip_address}"
    fgt_hub_a_private_ip_address_mgmt = "${azurerm_network_interface.fgt_hub_a_ifc_mgmt.private_ip_address}"
    fgt_hub_a_public_ip_address = "${data.azurerm_public_ip.fgt_hub_a_mgmt_pip.ip_address}"
    fgt_hub_b_private_ip_address_ext = "${azurerm_network_interface.fgt_hub_b_ifc_ext.private_ip_address}"
    fgt_hub_b_private_ip_address_int = "${azurerm_network_interface.fgt_hub_b_ifc_int.private_ip_address}"
    fgt_hub_b_private_ip_address_hasync = "${azurerm_network_interface.fgt_hub_b_ifc_hasync.private_ip_address}"
    fgt_hub_b_private_ip_address_mgmt = "${azurerm_network_interface.fgt_hub_b_ifc_mgmt.private_ip_address}"
    fgt_hub_b_public_ip_address = "${data.azurerm_public_ip.fgt_hub_b_mgmt_pip.ip_address}"
    fgt_branch1_private_ip_address_ext1 = "${azurerm_network_interface.fgt_branch1_ifc_ext1.private_ip_address}"
    fgt_branch1_private_ip_address_ext2 = "${azurerm_network_interface.fgt_branch1_ifc_ext2.private_ip_address}"
    fgt_branch1_private_ip_address_int = "${azurerm_network_interface.fgt_branch1_ifc_int.private_ip_address}"
    fgt_branch1_pip1 = "${data.azurerm_public_ip.fgt_branch1_pip1.ip_address}"
    fgt_branch1_pip2 = "${data.azurerm_public_ip.fgt_branch1_pip2.ip_address}"
    fgt_branch2_private_ip_address_ext1 = "${azurerm_network_interface.fgt_branch2_ifc_ext1.private_ip_address}"
    fgt_branch2_private_ip_address_ext2 = "${azurerm_network_interface.fgt_branch2_ifc_ext2.private_ip_address}"
    fgt_branch2_private_ip_address_int = "${azurerm_network_interface.fgt_branch2_ifc_int.private_ip_address}"
    fgt_branch2_pip1 = "${data.azurerm_public_ip.fgt_branch2_pip1.ip_address}"
    fgt_branch2_pip2 = "${data.azurerm_public_ip.fgt_branch2_pip2.ip_address}"
    fmg_private_ip_address = "${azurerm_network_interface.fmg_ifc.private_ip_address}"
    fmg_pip = "${data.azurerm_public_ip.fmg_pip.ip_address}"
    lnx_hub_private_ip_address = "${azurerm_network_interface.lnx_hub_ifc.private_ip_address}"
    lnx_hub_pip = "${data.azurerm_public_ip.lnx_hub_pip.ip_address}"
    lnx_branch1_private_ip_address = "${azurerm_network_interface.lnx_branch1_ifc.private_ip_address}"
    lnx_branch1_pip = "${data.azurerm_public_ip.lnx_branch1_pip.ip_address}"
    lnx_branch2_private_ip_address = "${azurerm_network_interface.lnx_branch2_ifc.private_ip_address}"
    lnx_branch2_pip = "${data.azurerm_public_ip.lnx_branch2_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
