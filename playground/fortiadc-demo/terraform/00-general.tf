##############################################################################################################
#
# FortiADC Azure Demo
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  description = "Added name to each deployed resource"
}

variable "LOCATION" {
  description = "Azure region"
}

variable "USERNAME" {
}

variable "PASSWORD" {
}

variable "BOOTDIAG_STORAGE" {
  description = "Storage account used for bootdiagnostics"
  default     = "jbidemofadsa" # Only lowercase letters and numbers. Name must be between 3 and 24 characters
}

##############################################################################################################
# FortiADC license type
##############################################################################################################

variable "IMAGESKUFAD" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default     = "fad-vm-byol"
}

variable "FAD_LICENSE_FILE_A" {
  default = ""
}

variable "FAD_LICENSE_FILE_B" {
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
  default     = "10.150.0.0/16"
}

variable "subnet" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.150.0.0/24"  # External
    "2" = "10.150.1.0/24"  # Internal
    "3" = "10.150.10.0/24" # Protected a
    "4" = "10.150.11.0/24" # Protected b
  }
}

variable "subnetmask" {
  type        = map(string)
  description = ""

  default = {
    "1" = "24" # External
    "2" = "24" # Internal
    "3" = "24" # Protected a
    "4" = "24" # Protected b
  }
}

variable "fad_ipaddress_a" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.150.0.4" # External
    "2" = "10.150.1.4" # Internal
    "3" = "10.150.0.6" # Floating
  }
}

variable "fad_ipaddress_b" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.150.0.5" # External
    "2" = "10.150.1.5" # Internal
  }
}

variable "gateway_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.150.0.1"  # External
    "2" = "10.150.1.1"  # Internal
    "3" = "10.150.10.1" # Protected A
    "4" = "10.150.11.1" # Protected B
  }
}

variable "fad_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - Ubuntu network
##############################################################################################################

variable "lnx_vmsize" {
  default = "Standard_B1s"
}

variable "lnx_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.150.10.4" # UBUNTU-A
    "2" = "10.150.11.4" # UBUNTU-B
  }
}

##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = var.LOCATION
}

##############################################################################################################
