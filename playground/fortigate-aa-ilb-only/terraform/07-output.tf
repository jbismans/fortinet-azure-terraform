##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    fgt_hub_a_private_ip_address = "${azurerm_network_interface.fgt_hub_a_ifc.private_ip_address}"
    fgt_hub_b_private_ip_address = "${azurerm_network_interface.fgt_hub_b_ifc.private_ip_address}"
    fgt_hub_c_private_ip_address = "${azurerm_network_interface.fgt_hub_c_ifc.private_ip_address}"
    jumpstation_private_ip_address = "${azurerm_network_interface.jumpstation_ifc.private_ip_address}"
    jumpstation_public_ip_address = "${data.azurerm_public_ip.jumpstation_pip.ip_address}"
    lnx_spoke1_private_ip_address = "${azurerm_network_interface.lnx_spoke1_ifc.private_ip_address}"
    lnx_spoke2_private_ip_address = "${azurerm_network_interface.lnx_spoke2_ifc.private_ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
