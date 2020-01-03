##############################################################################################################
#
# FortiGate internal loadbalanced Active/Active
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  description = "Added name to each deployed resource"
}

variable "LOCATION" {
  description = "Azure region"
}

variable "USERNAME" {}

variable "PASSWORD" {}

##############################################################################################################
# FortiGate license type
##############################################################################################################

variable "IMAGESKUFGT" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default = "fortinet_fg-vm"
}

variable "FGT_LICENSE_FILE_HUB_A" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_B" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_C" {
  default = ""
}

##############################################################################################################
# Minimum terraform version
##############################################################################################################

terraform {
  required_version = ">= 0.12"
}

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################

provider "azurerm" {
}

##############################################################################################################
# Static variables - HUB network
##############################################################################################################

variable "vnet_hub" {
  description = ""
  default = "10.0.0.0/16"
}

variable "subnet_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.0/24"         # FortiGate subnet
    "2" = "10.0.254.0/24"         # Jumpstation subnet
    # "3" = "10.0.10.0/24"        # Protected a
    # "4" = "10.0.11.0/24"        # Protected b
  }
}

variable "subnetmask_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # FortiGate subnet
    "2" = "24"        # Jumpstation subnet
    # "3" = "24"        # Protected a
    # "4" = "24"        # Protected b
  }
}

variable "fgt_hub_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.4"      # FortiGate A
    "2" = "10.0.0.5"      # FortiGate B
    "3" = "10.0.0.6"      # FortiGate C
  }
}

variable "gateway_ipaddress_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.1"      # FortiGate subnet
    "2" = "10.0.254.1"    # Jumpstation subnet
  }
}

variable "ilb_internal_ipaddress_hub" {
  description = ""

  default = "10.0.0.254"
}

variable "fgt_vmsize_hub" {
  default = "Standard_F4s"
}

variable "jumpstation_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.254.4"      # Jumpstation
  }
}

variable "jumpstation_vmsize" {
  default = "Standard_D2s_v3"
}

##############################################################################################################
# Static variables - SPOKE 1 network
##############################################################################################################

variable "vnet_spoke1" {
  description = ""
  default = "10.1.0.0/16"
}

variable "subnet_spoke1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.0/24"         # protected a
  }
}

variable "subnetmask_spoke1" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # protected a
  }
}

variable "lnx_ipaddress_spoke1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.4"       # Linux a
  }
}

variable "gateway_ipaddress_spoke1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.1"       # protected a
  }
}

variable "lnx_vmsize_spoke1" {
  default = "Standard_F2s"
}

##############################################################################################################
# Static variables - SPOKE 2 network
##############################################################################################################

variable "vnet_spoke2" {
  description = ""
  default = "10.2.0.0/16"
}

variable "subnet_spoke2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.0/24"         # protected a
  }
}

variable "subnetmask_spoke2" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # protected a
  }
}

variable "lnx_ipaddress_spoke2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.4"       # Linux a
  }
}

variable "gateway_ipaddress_spoke2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.1"       # protected a
  }
}

variable "lnx_vmsize_spoke2" {
  default = "Standard_F2s"
}

##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = "${var.LOCATION}"
}

##############################################################################################################
