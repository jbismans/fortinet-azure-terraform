##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    fgt_a_private_ip_address_transit = "${azurerm_network_interface.fgt_a_ifc_transit.private_ip_address}"
    fgt_a_private_ip_address_lan = "${azurerm_network_interface.fgt_a_ifc_lan.private_ip_address}"
    fgt_a_public_ip_address = "${data.azurerm_public_ip.fgt_a_pip.ip_address}"
    fgt_b_private_ip_address_transit = "${azurerm_network_interface.fgt_b_ifc_transit.private_ip_address}"
    fgt_b_private_ip_address_lan = "${azurerm_network_interface.fgt_b_ifc_lan.private_ip_address}"
    fgt_b_public_ip_address = "${data.azurerm_public_ip.fgt_b_pip.ip_address}"
    fts_private_ip_address_port1 = "${azurerm_network_interface.fts_ifc_lan_a.private_ip_address}"
    fts_private_ip_address_port2 = "${azurerm_network_interface.fts_ifc_lan_b.private_ip_address}"
    fts_private_ip_address_mgmt = "${azurerm_network_interface.fts_ifc_mgmt.private_ip_address}"
    fts_public_ip_address = "${data.azurerm_public_ip.fts_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
