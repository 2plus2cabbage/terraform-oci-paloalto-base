                                                                               # Creates a security list for the trust subnet with specific rules for internal traffic
resource "oci_core_security_list" "trust_security_list" {
  compartment_id           = var.compartment_ocid                              # Compartment for the security list
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                       # VCN ID for the security list
  display_name             = "${local.security_list_name_prefix}-trust-001"    # Name of the trust security list

                                                                               # Egress rule: Allow all outbound traffic from the trust subnet
  egress_security_rules {
    protocol               = "all"                                             # Allow all protocols
    destination            = "0.0.0.0/0"                                       # Allow to any destination
    description            = "Allow all outbound traffic from trust subnet"
  }

                                                                               # Ingress rule: Allow all inbound traffic to the trust subnet (controlled by firewall)
  ingress_security_rules {
    protocol               = "all"                                             # Allow all protocols
    source                 = "0.0.0.0/0"                                       # Allow from any source
    description            = "Allow all inbound traffic to trust subnet (firewall-controlled)"
  }
}

                                                                               # Creates a security list for the untrust subnet with open inbound traffic (firewall-controlled)
resource "oci_core_security_list" "untrust_security_list" {
  compartment_id           = var.compartment_ocid                              # Compartment for the security list
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                       # VCN ID for the security list
  display_name             = "${local.security_list_name_prefix}-untrust-001"  # Name of the untrust security list

                                                                               # Egress rule: Allow all outbound traffic from the untrust subnet
  egress_security_rules {
    protocol               = "all"                                             # Allow all protocols
    destination            = "0.0.0.0/0"                                       # Allow to any destination
    description            = "Allow all outbound traffic from untrust subnet"
  }

                                                                               # Ingress rule: Allow all inbound traffic to the untrust subnet (firewall-controlled)
  ingress_security_rules {
    protocol               = "all"                                             # Allow all protocols
    source                 = "0.0.0.0/0"                                       # Allow from any source
    description            = "Allow all inbound traffic to untrust subnet (firewall-controlled)"
  }
}

                                                                               # Creates a security list for the management subnet with specific rules for SSH and SSL
resource "oci_core_security_list" "mgmt_security_list" {
  compartment_id           = var.compartment_ocid                              # Compartment for the security list
  vcn_id                   = oci_core_vcn.cabbage_vcn.id                       # VCN ID for the security list
  display_name             = "${local.security_list_name_prefix}-mgmt-001"     # Name of the management security list

                                                                               # Egress rule: Allow all outbound traffic from the management subnet
  egress_security_rules {
    protocol               = "all"                                             # Allow all protocols
    destination            = "0.0.0.0/0"                                       # Allow to any destination
    description            = "Allow all outbound traffic from management subnet"
  }

                                                                               # Ingress rule: Allow SSL (TCP 443) from your public IP to the firewall management interface
  ingress_security_rules {
    protocol               = "6"                                               # TCP protocol
    source                 = var.my_public_ip                                  # Source IP for SSL access
    tcp_options {
      min                  = 443                                               # Minimum port (SSL)
      max                  = 443                                               # Maximum port (SSL)
    }
    description            = "SSL from your IP to firewall management"
  }

                                                                               # Ingress rule: Allow SSH (TCP 22) from your public IP to the firewall management interface
  ingress_security_rules {
    protocol               = "6"                                               # TCP protocol
    source                 = var.my_public_ip                                  # Source IP for SSH access
    tcp_options {
      min                  = 22                                                # Minimum port (SSH)
      max                  = 22                                                # Maximum port (SSH)
    }
    description            = "SSH from your IP to firewall management"
  }
}