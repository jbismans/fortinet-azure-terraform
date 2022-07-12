##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    fmg_private_ip_address = "${azurerm_network_interface.fmg_ifc.private_ip_address}"
    fmg_pip = "${data.azurerm_public_ip.fmg_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
