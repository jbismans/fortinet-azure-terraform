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
    fgt_hub_a_public_ip_address = "${data.azurerm_public_ip.fgt_hub_a_ext_pip.ip_address}"
    fgt_hub_b_private_ip_address_ext = "${azurerm_network_interface.fgt_hub_b_ifc_ext.private_ip_address}"
    fgt_hub_b_private_ip_address_int = "${azurerm_network_interface.fgt_hub_b_ifc_int.private_ip_address}"
    fgt_hub_b_public_ip_address = "${data.azurerm_public_ip.fgt_hub_b_ext_pip.ip_address}"
    lnx_spoke1_private_ip_address = "${azurerm_network_interface.lnx_spoke1_ifc.private_ip_address}"
    lnx_spoke2_private_ip_address = "${azurerm_network_interface.lnx_spoke2_ifc.private_ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
