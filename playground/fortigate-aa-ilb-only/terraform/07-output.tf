##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = "${file("${path.module}/summary.tpl")}"

  vars = {
    location = "${var.LOCATION}"
    bastion_public_ip_address = "${data.azurerm_public_ip.bastion_pip.ip_address}"
    fgt_ext_a_mgmt_ip_address = "${data.azurerm_public_ip.fgt_ext_hub_a_mgmt_pip.ip_address}"
    fgt_ext_b_mgmt_ip_address = "${data.azurerm_public_ip.fgt_ext_hub_b_mgmt_pip.ip_address}"
    fgt_ext_plb_ip_address    = "${data.azurerm_public_ip.plb_ext_hub_pip.ip_address}"
  }
}

output "deployment_summary" {
  value = "${data.template_file.summary.rendered}"
}
