##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    fgt_private_ip_address_ext = "${azurerm_network_interface.fgt_ifc_ext.private_ip_address}"
    fgt_private_ip_address_int = "${azurerm_network_interface.fgt_ifc_int.private_ip_address}"
    fgt_pip1 = "${data.azurerm_public_ip.fgt_pip1.ip_address}"
    fac_a_private_ip_address = "${azurerm_network_interface.fac_a_ifc.private_ip_address}"
    fac_b_private_ip_address = "${azurerm_network_interface.fac_b_ifc.private_ip_address}"
    win_srv_private_ip_address = "${azurerm_network_interface.win_server_ifc.private_ip_address}"
    win_clnt_private_ip_address = "${azurerm_network_interface.win_client_ifc.private_ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
