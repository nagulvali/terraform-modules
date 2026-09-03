# TODO: AWS Networking Module

## Implemented
- [x] VPC (multiple VPCs with for_each)
- [x] Subnets (with vpc_ref_key)
- [x] Internet Gateway (with vpc_ref_key)
- [x] Route Tables (with routes and associations)
- [x] Elastic IPs
- [x] NAT Gateways (with subnet_ref_key, eip_ref_key)
- [x] VPC Endpoints (Gateway and Interface types)

## Pending
- [ ] Security Groups
- [ ] Network ACLs
- [ ] VPC Peering
- [ ] Transit Gateway
- [ ] VPN Connections
- [ ] Direct Connect
- [ ] AWS PrivateLink (partial - Interface endpoints done)
- [ ] AWS Global Accelerator

## Enhancements
- [ ] Add random string to each resource naming convention
- [ ] Add support for IPv6
- [ ] Add flow logs support
- [ ] Add DHCP options set support
