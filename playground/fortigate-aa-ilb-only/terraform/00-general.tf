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

variable "USERNAME" {
}

variable "PASSWORD" {
}

##############################################################################################################
# FortiGate license type
##############################################################################################################

variable "IMAGESKUFGT" {
  description = "Azure Marketplace Image SKU hourly (PAYG) or BYOL (Bring your own license)"
  default     = "fortinet_fg-vm"
}

variable "FGT_LICENSE_FILE_HUB_INT_A" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_INT_B" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_INT_C" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_EXT_A" {
  default = ""
}

variable "FGT_LICENSE_FILE_HUB_EXT_B" {
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
  default     = "192.168.136.0/22"
}

variable "subnet_hub" {
  type        = map(string)
  description = ""

  default = {
    "fgt_ext_wan"    = "192.168.136.0/26"
    "fgt_ext_lan"    = "192.168.136.64/26"
    "fgt_ext_hasync" = "192.168.136.128/26"
    "fgt_ext_mgmt"   = "192.168.136.192/26"
    "fgt_int"        = "192.168.137.0/26"
    "bastion"        = "192.168.137.64/26"
    "dmz_ext_shrd"   = "192.168.138.0/26"
    "dmz_pub"        = "192.168.138.64/26"
    "dmz_int_shrd"   = "192.168.138.128/26"
  }
}

variable "subnetmask_hub" {
  type        = map(string)
  description = ""

  default = {
    "fgt_ext_wan"    = "26"
    "fgt_ext_lan"    = "26"
    "fgt_ext_hasync" = "26"
    "fgt_ext_mgmt"   = "26"
    "fgt_int"        = "26"
    "bastion"        = "26"
    "dmz_ext_shrd"   = "26"
    "dmz_pub"        = "26"
    "dmz_int_shrd"   = "26"
  }
}

variable "fgt_ext_hub_ipaddress_a" {
  type        = map(string)
  description = ""

  default = {
    "1" = "192.168.136.4"   # External
    "2" = "192.168.136.68"  # Internal
    "3" = "192.168.136.132" # HASYNC
    "4" = "192.168.136.196" # MGMT
  }
}

variable "fgt_ext_hub_ipaddress_b" {
  type        = map(string)
  description = ""

  default = {
    "1" = "192.168.136.5"   # External
    "2" = "192.168.136.69"  # Internal
    "3" = "192.168.136.133" # HASYNC
    "4" = "192.168.136.197" # MGMT
  }
}

variable "fgt_int_hub_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "A" = "192.168.137.4" # FortiGate A
    "B" = "192.168.137.5" # FortiGate B
    "C" = "192.168.137.6" # FortiGate C
  }
}

variable "gateway_ipaddress_hub" {
  type        = map(string)
  description = ""

  default = {
    "fgt_ext_wan"    = "192.168.136.1"
    "fgt_ext_lan"    = "192.168.136.65"
    "fgt_ext_hasync" = "192.168.136.129"
    "fgt_ext_mgmt"   = "192.168.136.193"
    "fgt_int"        = "192.168.137.1"
    "bastion"        = "192.168.137.65"
    "dmz_ext_shrd"   = "192.168.138.1"
    "dmz_pub"        = "192.168.138.65"
    "dmz_int_shrd"   = "192.168.138.129"
  }
}

variable "ilb_ext_fgt_ipaddress_hub" {
  description = ""

  default = "192.168.136.126"
}

variable "ilb_int_fgt_ipaddress_hub" {
  description = ""

  default = "192.168.137.62"
}

variable "fgt_vmsize_hub" {
  default = "Standard_F4s"
}

variable "bastion_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "192.168.137.68" # bastion
  }
}

variable "bastion_vmsize" {
  default = "Standard_D2s_v3"
}

##############################################################################################################
# Static variables - SPOKE 1 network
##############################################################################################################

variable "vnet_spoke1" {
  description = ""
  default     = "192.168.142.0/24"
}

variable "subnet_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "192.168.142.0/26"
    "middleware" = "192.168.142.64/26"
    "backend"    = "192.168.142.128/26"
  }
}

variable "subnetmask_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "26"
    "middleware" = "26"
    "backend"    = "26"
  }
}

variable "lnx_ipaddress_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "1" = "192.168.142.4" # Linux a
  }
}

variable "gateway_ipaddress_spoke1" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "192.168.142.1"
    "middleware" = "192.168.142.65"
    "backend"    = "192.168.142.129"
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
  default     = "192.168.143.0/24"
}

variable "subnet_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "192.168.143.0/26"
    "middleware" = "192.168.143.64/26"
    "backend"    = "192.168.143.128/26"
  }
}

variable "subnetmask_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "26"
    "middleware" = "26"
    "backend"    = "26"
  }
}

variable "lnx_ipaddress_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "1" = "192.168.143.4" # Linux a
  }
}

variable "gateway_ipaddress_spoke2" {
  type        = map(string)
  description = ""

  default = {
    "frontend"   = "192.168.143.1"
    "middleware" = "192.168.143.65"
    "backend"    = "192.168.143.129"
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
