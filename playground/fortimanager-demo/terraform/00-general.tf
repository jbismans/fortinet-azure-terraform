##############################################################################################################
#
# Demo FortiManager
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
  default = "jbidemofmgsa" # Only lowercase letters and numbers. Name must be between 3 and 24 characters
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
# Static variables - FMG network
##############################################################################################################

variable "IMAGESKUFMG" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default = "fortinet-fortimanager"
}

variable "vnet_fmg" {
  description = ""
  default = "10.140.0.0/16"
}

variable "subnet_fmg" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.140.0.0/24"     #External
  }
}

variable "fmg_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.140.0.4"        # External
  }
}

variable "fmg_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = "${var.LOCATION}"
}

##############################################################################################################
