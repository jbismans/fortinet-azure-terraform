##############################################################################################################
#
# Terraform configuration
#
##############################################################################################################

data "template_file" "summary" {
  template = file("${path.module}/summary.tpl")

  vars = {
    location                     = var.LOCATION
    #floating_public_ipaddress    = data.azurerm_public_ip.fad_floating_pip.ip_address
    fad_a_private_ip_address_ext = azurerm_network_interface.fad_a_ifc_ext.private_ip_address
    fad_a_private_ip_address_int = azurerm_network_interface.fad_a_ifc_int.private_ip_address
    #fad_a_public_ip_address      = data.azurerm_public_ip.fad_a_pip.ip_address
    fad_b_private_ip_address_ext = azurerm_network_interface.fad_b_ifc_ext.private_ip_address
    fad_b_private_ip_address_int = azurerm_network_interface.fad_b_ifc_int.private_ip_address
    #fad_b_public_ip_address      = data.azurerm_public_ip.fad_b_pip.ip_address
    lnx_a_private_ip_address     = azurerm_network_interface.lnx_a_ifc.private_ip_address
    #lnx_a_pip                    = data.azurerm_public_ip.lnx_a_pip.ip_address
    lnx_b_private_ip_address     = azurerm_network_interface.lnx_b_ifc.private_ip_address
    #lnx_b_pip                    = data.azurerm_public_ip.lnx_b_pip.ip_address
  }
}

output "deployment_summary" {
  value = data.template_file.summary.rendered
}

