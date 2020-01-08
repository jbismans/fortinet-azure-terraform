# fortigate-aa-ilb-only

This template was created for a customer.
This deploys:
- Hub vnet with 2 spoke vnets with vnet peering
- a loadbalanced A/P FortiGate cluster for North/South traffic (Internet, IPsec,...)
- a loadbalanced A/A/A FortiGate cluster for East/West traffic (internal segmentation, Expressroute,...)
- a Windows server used as Bastion/Jumpstation for management
- Two Ubuntu VM's in each spoke for testing purposes