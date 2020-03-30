##############################################################################################################
#
# Fortitester internal throughput
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

##############################################################################################################
# FortiGate license
##############################################################################################################

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
# Static variables - FortiGate network
##############################################################################################################

variable "vnet" {
  description = ""
  default     = "10.0.0.0/16"
}

variable "subnet" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.0.0.0/24" # port1
    "2" = "10.0.1.0/24" # port2
    "3" = "10.0.2.0/24" # mgmt
  }
}

variable "subnetmask" {
  type        = map(string)
  description = ""

  default = {
    "1" = "24" # port1
    "2" = "24" # port2
    "3" = "24" # mgmt
  }
}

variable "gateway_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.0.0.1" # port1
    "2" = "10.0.1.1" # port2
    "3" = "10.0.2.1" # mgmt
  }
}

variable "fgt_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.0.0.4" # port1
    "2" = "10.0.1.4" # port2
  }
}

variable "fgt_vmsize" {
  default = "Standard_DS3_v2"
}

##############################################################################################################
# Static variables - FortiTester network
##############################################################################################################

variable "fts_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.0.0.5" # port1
    "2" = "10.0.1.5" # port2
    "3" = "10.0.2.5" # mgmt
  }
}

variable "fts_size" {
  default = "Standard_DS5_v2"
}

##############################################################################################################
# Resource Group
##############################################################################################################

resource "azurerm_resource_group" "resourcegroup" {
  name     = "${var.PREFIX}-RG"
  location = var.LOCATION
}

##############################################################################################################
