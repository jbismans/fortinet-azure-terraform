##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    plb_ipaddress = "${data.azurerm_public_ip.plb_fwb_pip.ip_address}"
    fwb_a_private_ip_address_ext = "${azurerm_network_interface.fwb_a_ifc_ext.private_ip_address}"
    fwb_a_private_ip_address_int = "${azurerm_network_interface.fwb_a_ifc_int.private_ip_address}"
    fwb_a_public_ip_address = "${data.azurerm_public_ip.fwb_a_pip.ip_address}"
    fwb_b_private_ip_address_ext = "${azurerm_network_interface.fwb_b_ifc_ext.private_ip_address}"
    fwb_b_private_ip_address_int = "${azurerm_network_interface.fwb_b_ifc_int.private_ip_address}"
    fwb_b_public_ip_address = "${data.azurerm_public_ip.fwb_b_pip.ip_address}"
    lnx_a_private_ip_address = "${azurerm_network_interface.lnx_a_ifc.private_ip_address}"
    lnx_a_pip = "${data.azurerm_public_ip.lnx_a_pip.ip_address}"
    lnx_b_private_ip_address = "${azurerm_network_interface.lnx_b_ifc.private_ip_address}"
    lnx_b_pip = "${data.azurerm_public_ip.lnx_b_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
