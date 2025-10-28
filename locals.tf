                                                                                       # Defines local variables for resource naming conventions in OCI
locals {
  vcn_name_prefix            = "vcn-${var.environment_name}-${var.location}"           # Prefix for VCN name
  trust_subnet_name_prefix   = "snet-${var.environment_name}-${var.location}-trust"    # Prefix for trust subnet name
  untrust_subnet_name_prefix = "snet-${var.environment_name}-${var.location}-untrust"  # Prefix for untrust subnet name
  mgmt_subnet_name_prefix    = "snet-${var.environment_name}-${var.location}-mgmt"     # Prefix for management subnet name
  security_list_name_prefix  = "slist-${var.environment_name}-${var.location}"         # Prefix for security list names
  route_table_name_prefix    = "rt-${var.environment_name}-${var.location}"            # Prefix for route table names
  firewall_name_prefix       = "fw-${var.environment_name}-${var.location}"            # Prefix for firewall instance name
  windows_name_prefix        = "vm-${var.environment_name}-${var.location}-windows"    # Prefix for Windows instance name
  trust_vnic_name_prefix     = "vnic-${var.environment_name}-${var.location}-trust"    # Prefix for firewall trust VNIC name
  untrust_vnic_name_prefix   = "vnic-${var.environment_name}-${var.location}-untrust"  # Prefix for firewall untrust VNIC name
  mgmt_vnic_name_prefix      = "vnic-${var.environment_name}-${var.location}-mgmt"     # Prefix for firewall management VNIC name
}