##############################################################################################################
#
# Demo FortiGate loadbalanced Active/Passive
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
  default     = "jbidemofgtaplbsa" # Only lowercase letters and numbers. Name must be between 3 and 24 characters
}

##############################################################################################################
# FortiGate license type
##############################################################################################################

variable "IMAGESKUFGT" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default     = "fortinet_fg-vm"
}

variable "FGT_LICENSE_FILE_HUB_A" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_B" {
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
  features {
  }
}

##############################################################################################################
# Static variables - HUB network
##############################################################################################################

variable "vnet_hub" {
  description = ""
  default     = "10.110.0.0/16"
}

variable "subnet_hub" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.110.0.0/24"  # External
    "2" = "10.110.1.0/24"  # Internal
    "3" = "10.110.2.0/24"  # HASYNC
    "4" = "10.110.3.0/24"  # MGMT
    "5" = "10.110.10.0/24" # Protected a
    "6" = "10.110.11.0/24" # Protected b
  }
}

variable "subnetmask_hub" {
  type        = map(string)
  description = ""

  default = {
    "1" = "24" # External
    "2" = "24" # Internal
    "3" = "24" # HASYNC
    "4" = "24" # MGMT
    "5" = "24" # Protected a
    "6" = "24" # Protected b
  }
}

variable "fgt_hub_ipaddress_a" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.110.0.4" # External
    "2" = "10.110.1.4" # Internal
    "3" = "10.110.2.4" # HASYNC
    "4" = "10.110.3.4" # MGMT
  }
}

variable "fgt_hub_ipaddress_b" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.110.0.5" # External
    "2" = "10.110.1.5" # Internal
    "3" = "10.110.2.5" # HASYNC
    "4" = "10.110.3.5" # MGMT
  }
}

variable "gateway_ipaddress_hub" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.110.0.1" # External
    "2" = "10.110.1.1" # Internal
    "3" = "10.110.2.1" # HASYNC
    "4" = "10.110.3.1" # MGMT
  }
}

variable "ilb_internal_ipaddress_hub" {
  description = ""

  default = "10.110.1.254"
}

variable "fgt_vmsize_hub" {
  default = "Standard_F4s"
}

##############################################################################################################
# Static variables - SPOKE 1 network
##############################################################################################################

variable "vnet_spoke1" {
  description = ""
  default     = "10.111.0.0/16"
}

variable "subnet_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.111.0.0/24" # protected a
  }
}

variable "subnetmask_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "1" = "24" # protected a
  }
}

variable "lnx_ipaddress_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.111.0.4" # Linux a
  }
}

variable "gateway_ipaddress_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.111.0.1" # protected a
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
  default     = "10.112.0.0/16"
}

variable "subnet_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.112.0.0/24" # protected a
  }
}

variable "subnetmask_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "1" = "24" # protected a
  }
}

variable "lnx_ipaddress_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.112.0.4" # Linux a
  }
}

variable "gateway_ipaddress_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "1" = "10.112.0.1" # protected a
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
  location = var.LOCATION
}

##############################################################################################################
