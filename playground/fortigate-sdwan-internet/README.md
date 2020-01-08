# fortiauthenticator-ha

This template was created to create an SD-WAN testing lab in Azure

This deploys:
- Hub:
    - A loadbalanced Active/Passive FortiGate cluster
    - An Ubuntu VM for testing purposes

- Branch:
    - Two branches
    - Single FortiGate with two WAN interfaces
    - Ubuntu VM for testing purposes

- A FortiManager