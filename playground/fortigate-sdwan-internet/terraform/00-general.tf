##############################################################################################################
#
# FortiGate SD-WAN deployment
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

variable "FGT_LICENSE_FILE_BRANCH1" {
  default = ""
}

variable "FGT_LICENSE_FILE_BRANCH2" {
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

variable "vnet_hub" {
  description = ""
  default = "10.0.0.0/16"
}

variable "subnet_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.0/24"         # External
    "2" = "10.0.1.0/24"         # Internal
    "3" = "10.0.2.0/24"         # HASYNC
    "4" = "10.0.3.0/24"         # MGMT
    "5" = "10.0.10.0/24"        # Protected a
    "6" = "10.0.11.0/24"        # Protected b
  }
}

variable "subnetmask_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # External
    "2" = "24"        # Internal
    "3" = "24"        # HASYNC
    "4" = "24"        # MGMT
    "5" = "24"        # Protected a
    "6" = "24"        # Protected b
  }
}

variable "fgt_hub_ipaddress_a" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.4"      # External
    "2" = "10.0.1.4"      # Internal
    "3" = "10.0.2.4"      # HASYNC
    "4" = "10.0.3.4"      # MGMT
  }
}

variable "fgt_hub_ipaddress_b" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.5"      # External
    "2" = "10.0.1.5"      # Internal
    "3" = "10.0.2.5"      # HASYNC
    "4" = "10.0.3.5"      # MGMT
  }
}

variable "gateway_ipaddress_hub" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.0.1"      # External
    "2" = "10.0.1.1"      # Internal
    "3" = "10.0.2.1"      # HASYNC
    "4" = "10.0.3.1"      # MGMT
  }
}

variable "ilb_internal_ipaddress_hub" {
  description = ""

  default = "10.0.1.254"
}

variable "fgt_vmsize_hub" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - BRANCH 1 network
##############################################################################################################

variable "vnet_branch1" {
  description = ""
  default = "10.1.0.0/16"
}

variable "subnet_branch1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.0/24"         # External1
    "2" = "10.1.1.0/24"         # External2
    "3" = "10.1.2.0/24"         # Internal
    "4" = "10.1.10.0/24"        # Protected a
    "5" = "10.1.11.0/24"        # Protected b
  }
}

variable "subnetmask_branch1" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # External1
    "2" = "24"        # External2
    "3" = "24"        # Internal
    "4" = "24"        # Protected a
    "5" = "24"        # Protected b
  }
}

variable "fgt_ipaddress_branch1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.4"       # External1
    "2" = "10.1.1.4"       # External2
    "3" = "10.1.2.4"       # Internal
  }
}

variable "gateway_ipaddress_branch1" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.1.0.1"       # External1
    "2" = "10.1.1.1"       # External2
    "3" = "10.1.2.1"       # Internal
  }
}

variable "fgt_vmsize_branch1" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - BRANCH 2 network
##############################################################################################################

variable "vnet_branch2" {
  description = ""
  default = "10.2.0.0/16"
}

variable "subnet_branch2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.0/24"         # External1
    "2" = "10.2.1.0/24"         # External2
    "3" = "10.2.2.0/24"         # Internal
    "4" = "10.2.10.0/24"        # Protected a
    "5" = "10.2.11.0/24"        # Protected b
  }
}

variable "subnetmask_branch2" {
  type        = "map"
  description = ""

  default = {
    "1" = "24"        # External1
    "2" = "24"        # External2
    "3" = "24"        # Internal
    "4" = "24"        # Protected a
    "5" = "24"        # Protected b
  }
}

variable "fgt_ipaddress_branch2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.4"       # External1
    "2" = "10.2.1.4"       # External2
    "3" = "10.2.2.4"       # Internal
  }
}

variable "gateway_ipaddress_branch2" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.2.0.1"       # External1
    "2" = "10.2.1.1"       # External2
    "3" = "10.2.2.1"       # Internal
  }
}

variable "fgt_vmsize_branch2" {
  default = "Standard_F4s"
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
  default = "172.16.0.0/16"
}

variable "subnet_fmg" {
  type        = "map"
  description = ""

  default = {
    "1" = "172.16.0.0/24"     #External
  }
}

variable "fmg_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "172.16.0.4"        # External
  }
}

variable "fmg_vmsize" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - Ubuntu network
##############################################################################################################

variable "lnx_vmsize" {
  default = "Standard_F2s"  # Needs to support accelerated networking
}

variable "lnx_ipaddress" {
  type        = "map"
  description = ""

  default = {
    "1" = "10.0.10.4"        # HUB
    "2" = "10.1.10.4"        # BRANCH1
    "3" = "10.2.10.4"        # BRANCH2
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
