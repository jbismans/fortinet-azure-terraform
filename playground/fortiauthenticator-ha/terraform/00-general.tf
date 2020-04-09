##############################################################################################################
#
# ETEX FAC TESTING 
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

variable "FGT_LICENSE_FILE" {
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
  features {}
}

##############################################################################################################
# Static variables - BRANCH 1 network
##############################################################################################################

variable "vnet" {
  description = ""
  default = "10.1.0.0/16"
}

variable "subnet" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.0/24"         # External
    "2" = "10.1.1.0/24"         # Internal
    "3" = "10.1.10.0/24"        # Protected a
    "4" = "10.1.11.0/24"        # Protected b
  }
}

variable "subnetmask" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # External1
    "2" = "24"        # Internal
    "3" = "24"        # Protected a
    "4" = "24"        # Protected b
  }
}

variable "fgt_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.4"       # External1
    "2" = "10.1.1.4"       # Internal
  }
}

variable "gateway_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.1"       # External1
    "2" = "10.1.1.1"       # Internal
  }
}

variable "fgt_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - FAC
##############################################################################################################

variable "fac_vmsize" {
  default = "Standard_F2s_v2"
}

variable "fac_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.10.4"        # FACA
    "2" = "10.1.10.5"        # FACB
  }
}

##############################################################################################################
# Static variables - VM's
##############################################################################################################

variable "vm_vmsize" {
  default = "Standard_D2s_v3"
}

variable "vm_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.10.10"        # DC
    "2" = "10.1.10.20"        # CLIENT
  }
}


##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = "${var.LOCATION}"
}

##############################################################################################################
