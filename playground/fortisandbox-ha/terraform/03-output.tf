##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    fsa_a_private_ip_address_ext = "${azurerm_network_interface.fsa_a_external_ifc.private_ip_address}"
    fsa_a_private_ip_address_int = "${azurerm_network_interface.fsa_a_internal_ifc.private_ip_address}"
    fsa_a_public_ip_address = "${data.azurerm_public_ip.fsa_a_pip.ip_address}"
    fsa_b_private_ip_address_ext = "${azurerm_network_interface.fsa_b_external_ifc.private_ip_address}"
    fsa_b_private_ip_address_int = "${azurerm_network_interface.fsa_b_internal_ifc.private_ip_address}"
    fsa_b_public_ip_address = "${data.azurerm_public_ip.fsa_b_pip.ip_address}"
    fsa_shared_public_ip_address = "${data.azurerm_public_ip.fsa_shared_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
