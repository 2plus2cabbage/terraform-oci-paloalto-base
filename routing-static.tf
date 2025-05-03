                                                                                            # Creates a route table for the trust subnet with a placeholder route
resource "oci_core_route_table" "trust_route_table" {
  compartment_id           = var.compartment_ocid                                           # Compartment for the route table
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                                    # VCN ID for the route table
  display_name             = "${local.route_table_name_prefix}-trust-001"                   # Name of the trust route table
  route_rules {
    destination            = "0.0.0.0/0"                                                    # Route all traffic
    network_entity_id      = data.oci_core_private_ips.trust_private_ips.private_ips[0].id  # Route to firewall trust interface
    description            = "Route to firewall trust interface"
  }
}

                                                                                            # Creates a route table for the untrust subnet to direct traffic to the internet
resource "oci_core_route_table" "untrust_route_table" {
  compartment_id           = var.compartment_ocid                                           # Compartment for the route table
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                                    # VCN ID for the route table
  display_name             = "${local.route_table_name_prefix}-untrust-001"                 # Name of the untrust route table
  route_rules {
    destination            = "0.0.0.0/0"                                                    # Route all traffic
    network_entity_id      = oci_core_internet_gateway.cabbage_igw.id                       # Direct to Internet Gateway
    description            = "Default route to Internet Gateway"
  }
}

                                                                                            # Creates a route table for the management subnet to direct traffic to the internet
resource "oci_core_route_table" "mgmt_route_table" {
  compartment_id           = var.compartment_ocid                                           # Compartment for the route table
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                                    # VCN ID for the route table
  display_name             = "${local.route_table_name_prefix}-mgmt-001"                    # Name of the management route table
  route_rules {
    destination            = "0.0.0.0/0"                                                    # Route all traffic
    network_entity_id      = oci_core_internet_gateway.cabbage_igw.id                       # Direct to Internet Gateway
    description            = "Default route to Internet Gateway"
  }
}