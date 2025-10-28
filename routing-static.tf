                                                                                                                               # Creates a route table for the trust subnet directing traffic to the firewall
resource "oci_core_route_table" "trust_route_table" {
  compartment_id      = var.compartment_ocid                                                                                   # Compartment for the route table
  vcn_id              = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the route table in
  display_name        = "${local.route_table_name_prefix}-trust-001"                                                           # Name of the trust route table using local prefix
  route_rules {
    destination       = "0.0.0.0/0"                                                                                            # Default route for all internet-bound traffic
    network_entity_id = data.oci_core_private_ips.trust_private_ips.private_ips[0].id                                          # Routes to firewall trust interface private IP
    description       = "Route to firewall trust interface"                                                                    # Description of the route rule
  }
}

                                                                                                                               # Creates a route table for the untrust subnet directing traffic to the internet
resource "oci_core_route_table" "untrust_route_table" {
  compartment_id      = var.compartment_ocid                                                                                   # Compartment for the route table
  vcn_id              = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the route table in
  display_name        = "${local.route_table_name_prefix}-untrust-001"                                                         # Name of the untrust route table using local prefix
  route_rules {
    destination       = "0.0.0.0/0"                                                                                            # Default route for all internet-bound traffic
    network_entity_id = oci_core_internet_gateway.cabbage_igw.id                                                               # Routes directly to Internet Gateway
    description       = "Default route to Internet Gateway"                                                                    # Description of the route rule
  }
}

                                                                                                                               # Creates a route table for the management subnet directing traffic to the internet
resource "oci_core_route_table" "mgmt_route_table" {
  compartment_id      = var.compartment_ocid                                                                                   # Compartment for the route table
  vcn_id              = oci_core_vcn.cabbage_vcn.id                                                                            # VCN to create the route table in
  display_name        = "${local.route_table_name_prefix}-mgmt-001"                                                            # Name of the management route table using local prefix
  route_rules {
    destination       = "0.0.0.0/0"                                                                                            # Default route for all internet-bound traffic
    network_entity_id = oci_core_internet_gateway.cabbage_igw.id                                                               # Routes directly to Internet Gateway
    description       = "Default route to Internet Gateway"                                                                    # Description of the route rule
  }
}