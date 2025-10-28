                                                                                                                                 # Creates a security list for the trust subnet allowing all traffic
resource "oci_core_security_list" "trust_security_list" {
  compartment_id = var.compartment_ocid                                                                                          # Compartment for the security list
  vcn_id         = oci_core_vcn.cabbage_vcn.id                                                                                   # VCN to create the security list in
  display_name   = "${local.security_list_name_prefix}-trust-001"                                                                # Name of the trust security list using local prefix

  egress_security_rules {
    protocol     = "all"                                                                                                         # Allows all protocols for outbound traffic
    destination  = "0.0.0.0/0"                                                                                                   # Allows traffic to any destination
    description  = "Allow all outbound traffic from trust subnet"                                                                # Description of the egress rule
  }

  ingress_security_rules {
    protocol     = "all"                                                                                                         # Allows all protocols for inbound traffic
    source       = "0.0.0.0/0"                                                                                                   # Allows traffic from any source
    description  = "Allow all inbound traffic to trust subnet controlled by Palo Alto firewall"                                  # Description of the ingress rule
  }
}

                                                                                                                                 # Creates a security list for the untrust subnet allowing all traffic
resource "oci_core_security_list" "untrust_security_list" {
  compartment_id = var.compartment_ocid                                                                                          # Compartment for the security list
  vcn_id         = oci_core_vcn.cabbage_vcn.id                                                                                   # VCN to create the security list in
  display_name   = "${local.security_list_name_prefix}-untrust-001"                                                              # Name of the untrust security list using local prefix

  egress_security_rules {
    protocol     = "all"                                                                                                         # Allows all protocols for outbound traffic
    destination  = "0.0.0.0/0"                                                                                                   # Allows traffic to any destination
    description  = "Allow all outbound traffic from untrust subnet"                                                              # Description of the egress rule
  }

  ingress_security_rules {
    protocol     = "all"                                                                                                         # Allows all protocols for inbound traffic
    source       = "0.0.0.0/0"                                                                                                   # Allows traffic from any source
    description  = "Allow all inbound traffic to untrust subnet controlled by Palo Alto firewall"                                # Description of the ingress rule
  }
}

                                                                                                                                 # Creates a security list for the management subnet restricting access to your IP
resource "oci_core_security_list" "mgmt_security_list" {
  compartment_id = var.compartment_ocid                                                                                          # Compartment for the security list
  vcn_id         = oci_core_vcn.cabbage_vcn.id                                                                                   # VCN to create the security list in
  display_name   = "${local.security_list_name_prefix}-mgmt-001"                                                                 # Name of the management security list using local prefix

  egress_security_rules {
    protocol     = "all"                                                                                                         # Allows all protocols for outbound traffic
    destination  = "0.0.0.0/0"                                                                                                   # Allows traffic to any destination
    description  = "Allow all outbound traffic from management subnet"                                                           # Description of the egress rule
  }

  ingress_security_rules {
    protocol     = "6"                                                                                                           # TCP protocol for HTTPS traffic
    source       = var.my_public_ip                                                                                              # Restricts source to your public IP only
    tcp_options {
      min        = 443                                                                                                           # HTTPS port for web management interface
      max        = 443                                                                                                           # HTTPS port for web management interface
    }
    description  = "Allow HTTPS from your IP to firewall management interface"                                                   # Description of the HTTPS ingress rule
  }

  ingress_security_rules {
    protocol     = "6"                                                                                                           # TCP protocol for SSH traffic
    source       = var.my_public_ip                                                                                              # Restricts source to your public IP only
    tcp_options {
      min        = 22                                                                                                            # SSH port for command line management
      max        = 22                                                                                                            # SSH port for command line management
    }
    description  = "Allow SSH from your IP to firewall management interface"                                                     # Description of the SSH ingress rule
  }
}