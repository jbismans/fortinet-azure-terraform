##############################################################################################################
#
# FortiWeb Azure Demo
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

variable "BOOTDIAG_STORAGE" {
  description = "Storage account used for bootdiagnostics"
  default = "jbidemofwbsa" # Only lowercase letters and numbers. Name must be between 3 and 24 characters
}

##############################################################################################################
# FortiWeb license type
##############################################################################################################

variable "IMAGESKUFWB" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default = "fortinet_fw-vm"
}

variable "FWB_LICENSE_FILE_A" {
  default = ""
}

variable "FWB_LICENSE_FILE_B" {
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
# Static variables - HUB network
##############################################################################################################

variable "vnet" {
  description = ""
  default = "10.100.0.0/16"
}

variable "subnet" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.100.0.0/24"         # External
    "2" = "10.100.1.0/24"         # Internal
    "3" = "10.100.10.0/24"        # Protected a
    "4" = "10.100.11.0/24"        # Protected b
  }
}

variable "subnetmask" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # External
    "2" = "24"        # Internal
    "3" = "24"        # Protected a
    "4" = "24"        # Protected b
  }
}

variable "fwb_ipaddress_a" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.100.0.4"      # External
    "2" = "10.100.1.4"      # Internal
  }
}

variable "fwb_ipaddress_b" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.100.0.5"      # External
    "2" = "10.100.1.5"      # Internal
  }
}

variable "gateway_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.100.0.1"      # External
    "2" = "10.100.1.1"      # Internal
    "3" = "10.100.10.1"     # Protected A
    "4" = "10.100.11.1"     # Protected B
  }
}

variable "fwb_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - Ubuntu network
##############################################################################################################

variable "lnx_vmsize" {
  default = "Standard_B1s"
}

variable "lnx_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.100.10.4"        # UBUNTU-A
    "2" = "10.100.11.4"        # UBUNTU-B
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
