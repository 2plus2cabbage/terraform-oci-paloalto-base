                                                                                  # Creates a Virtual Cloud Network (VCN) for the project
resource "oci_core_vcn" "cabbage_vcn" {
  compartment_id             = var.compartment_ocid                               # Compartment for the VCN
  display_name               = "${local.vcn_name_prefix}-001"                     # Name of the VCN
  cidr_blocks                = ["10.1.0.0/16"]                                    # CIDR block for the VCN
}

                                                                                  # Creates an Internet Gateway for outbound internet access
resource "oci_core_internet_gateway" "cabbage_igw" {
  compartment_id             = var.compartment_ocid                               # Compartment for the Internet Gateway
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                        # VCN ID for the Internet Gateway
  display_name               = "igw-${var.environment_name}-${var.location}-001"  # Name of the Internet Gateway
}

                                                                                  # Creates the trust subnet for the Windows Server
resource "oci_core_subnet" "trust_subnet" {
  compartment_id             = var.compartment_ocid                               # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                        # VCN ID for the subnet
  display_name               = "${local.trust_subnet_name_prefix}-001"            # Name of the trust subnet
  cidr_block                 = "10.1.1.0/24"                                      # CIDR block for the trust subnet
  security_list_ids          = [oci_core_security_list.trust_security_list.id]    # Security list for the trust subnet
  prohibit_public_ip_on_vnic = true                                               # Disallow public IPs in the trust subnet
}

                                                                                  # Creates the untrust subnet for the firewall's public-facing interface
resource "oci_core_subnet" "untrust_subnet" {
  compartment_id             = var.compartment_ocid                               # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                        # VCN ID for the subnet
  display_name               = "${local.untrust_subnet_name_prefix}-001"          # Name of the untrust subnet
  cidr_block                 = "10.1.2.0/24"                                      # CIDR block for the untrust subnet
  route_table_id             = oci_core_route_table.untrust_route_table.id        # Route table for the untrust subnet
  security_list_ids          = [oci_core_security_list.untrust_security_list.id]  # Security list for the untrust subnet
  prohibit_public_ip_on_vnic = false                                              # Allow public IPs in the untrust subnet
}

                                                                                  # Creates the management subnet for the firewall's management interface
resource "oci_core_subnet" "mgmt_subnet" {
  compartment_id             = var.compartment_ocid                               # Compartment for the subnet
  vcn_id                     = oci_core_vcn.cabbage_vcn.id                        # VCN ID for the subnet
  display_name               = "${local.mgmt_subnet_name_prefix}-001"             # Name of the management subnet
  cidr_block                 = "10.1.3.0/24"                                      # CIDR block for the management subnet
  route_table_id             = oci_core_route_table.mgmt_route_table.id           # Route table for the management subnet
  security_list_ids          = [oci_core_security_list.mgmt_security_list.id]     # Security list for the management subnet
  prohibit_public_ip_on_vnic = false                                              # Allow public IPs in the management subnet
}