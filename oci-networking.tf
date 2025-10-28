                                                                                                                                      # Creates a Virtual Cloud Network for the project
resource "oci_core_vcn" "cabbage_vcn" {
  compartment_id             = var.compartment_ocid                                                                                   # Compartment for the VCN
  display_name               = "${local.vcn_name_prefix}-001"                                                                         # Name of the VCN using local prefix
  cidr_blocks                = ["10.1.0.0/16"]                                                                                        # CIDR block for the entire VCN
}

                                                                                                                                      # Creates an Internet Gateway for outbound internet access
resource "oci_core_internet_gateway" "cabbage_igw" {
  compartment_id             = var.compartment_ocid                                                                                   # Compartment for the Internet Gateway
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to attach the Internet Gateway to
  display_name               = "igw-${var.environment_name}-${var.location}-001"                                                      # Name of the Internet Gateway
}

                                                                                                                                      # Creates the trust subnet for internal resources behind the firewall
resource "oci_core_subnet" "trust_subnet" {
  compartment_id             = var.compartment_ocid                                                                                   # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the subnet in
  display_name               = "${local.trust_subnet_name_prefix}-001"                                                                # Name of the trust subnet using local prefix
  cidr_block                 = "10.1.1.0/24"                                                                                          # CIDR block for the trust subnet
  security_list_ids          = [oci_core_security_list.trust_security_list.id]                                                        # Security list controlling trust subnet traffic
  prohibit_public_ip_on_vnic = true                                                                                                   # Prevents public IPs on instances in trust subnet
}

                                                                                                                                      # Creates the untrust subnet for the firewall external interface
resource "oci_core_subnet" "untrust_subnet" {
  compartment_id             = var.compartment_ocid                                                                                   # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the subnet in
  display_name               = "${local.untrust_subnet_name_prefix}-001"                                                              # Name of the untrust subnet using local prefix
  cidr_block                 = "10.1.2.0/24"                                                                                          # CIDR block for the untrust subnet
  route_table_id             = oci_core_route_table.untrust_route_table.id                                                            # Route table for internet-bound traffic
  security_list_ids          = [oci_core_security_list.untrust_security_list.id]                                                      # Security list controlling untrust subnet traffic
  prohibit_public_ip_on_vnic = false                                                                                                  # Allows public IPs for external connectivity
}

                                                                                                                                      # Creates the management subnet for the firewall management interface
resource "oci_core_subnet" "mgmt_subnet" {
  compartment_id             = var.compartment_ocid                                                                                   # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the subnet in
  display_name               = "${local.mgmt_subnet_name_prefix}-001"                                                                 # Name of the management subnet using local prefix
  cidr_block                 = "10.1.3.0/24"                                                                                          # CIDR block for the management subnet
  route_table_id             = oci_core_route_table.mgmt_route_table.id                                                               # Route table for management traffic
  security_list_ids          = [oci_core_security_list.mgmt_security_list.id]                                                         # Security list restricting management access
  prohibit_public_ip_on_vnic = false                                                                                                  # Allows public IP for management access
}