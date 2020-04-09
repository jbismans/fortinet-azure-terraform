##############################################################################################################
#
# FortiSandbox HA
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

variable "IMAGESKU" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default = "fortinet_fsa-vm"
}

variable "vnet" {
  description = ""
  default = "172.16.0.0/16"
}

variable "subnet" {
  type        = "map"
  description = ""

  default = {
    "1" = "172.16.0.0/24"     #External
    "2" = "172.16.1.0/24"     #Internal
  }
}

variable "fsa_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "172.16.0.4"        # External-fsa-a
    "2" = "172.16.0.5"        # External-fsa-b
    "3" = "172.16.1.4"        # Internal-fsa-a
    "4" = "172.16.1.5"        # Internal-fsa-b
    "5" = "172.16.0.10"       # Shared IP
  }
}

variable "fsa_vmsize" {
  default = "Standard_F8s"
}


##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = "${var.LOCATION}"
}

##############################################################################################################
