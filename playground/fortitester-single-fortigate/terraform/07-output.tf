##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = file("${path.module}/summary.tpl")

  vars = {
    location                     = var.LOCATION
    fgt_private_ip_address_port1 = azurerm_network_interface.fgt_ifc_port1.private_ip_address
    fgt_private_ip_address_port2 = azurerm_network_interface.fgt_ifc_port2.private_ip_address
    fgt_public_ip_address        = data.azurerm_public_ip.fgt_pip.ip_address
    fts_private_ip_address_port1 = azurerm_network_interface.fts_ifc_port1.private_ip_address
    fts_private_ip_address_port2 = azurerm_network_interface.fts_ifc_port2.private_ip_address
    fts_private_ip_address_mgmt  = azurerm_network_interface.fts_ifc_mgmt.private_ip_address
    fts_public_ip_address        = data.azurerm_public_ip.fts_pip.ip_address
  }
}

output "deployment_summary" {
  value = data.template_file.summary.rendered
}

