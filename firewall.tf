                                                                                                                                                                                      # Creates the Palo Alto firewall instance with the primary VNIC in the management subnet
resource "oci_core_instance" "firewall_instance" {
  availability_domain      = "gIaz:US-ASHBURN-AD-1"                                                                                                                                   # Availability domain for the firewall
  compartment_id           = var.compartment_ocid                                                                                                                                     # Compartment for the firewall
  shape                    = "VM.Standard3.Flex"                                                                                                                                      # Shape for the firewall
  shape_config {
    ocpus                  = 3                                                                                                                                                        # Number of OCPUs
    memory_in_gbs          = 42                                                                                                                                                       # Memory in GB
  }
  display_name             = "${local.firewall_name_prefix}-001"                                                                                                                      # Name of the firewall instance
  source_details {
    source_type            = "image"                                                                                                                                                  # Source type for the firewall
    source_id              = var.firewall_image_ocid                                                                                                                                  # Firewall image OCID from Marketplace
  }
  create_vnic_details {
    subnet_id              = oci_core_subnet.mgmt_subnet.id                                                                                                                           # Primary VNIC in management subnet
    display_name           = local.mgmt_vnic_name_prefix                                                                                                                              # Name of the primary VNIC
    assign_public_ip       = true                                                                                                                                                     # Assign an ephemeral public IP
  }
  metadata                 = {
    ssh_authorized_keys    = var.ssh_public_key                                                                                                                                       # SSH public key for admin user login
  }
}

                                                                                                                                                                                      # Creates a VNIC for the firewall's trust interface
resource "oci_core_vnic_attachment" "trust_vnic_attachment" {
  instance_id              = oci_core_instance.firewall_instance.id                                                                                                                   # Firewall instance ID
  display_name             = local.trust_vnic_name_prefix                                                                                                                             # Name of the trust VNIC
  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id                                                                                                                          # Trust subnet ID
    display_name           = local.trust_vnic_name_prefix                                                                                                                             # Name of the trust VNIC
    assign_public_ip       = false                                                                                                                                                    # No public IP for trust VNIC
    private_ip             = "10.1.1.10"                                                                                                                                              # Static IP for trust interface
    skip_source_dest_check = true                                                                                                                                                     # Disable src/dst check for routing
  }
}

                                                                                                                                                                                      # Fetches the private IPs associated with the trust VNIC to get the primary private IP ID
data "oci_core_private_ips" "trust_private_ips" {
  vnic_id                  = oci_core_vnic_attachment.trust_vnic_attachment.vnic_id                                                                                                   # Trust VNIC ID
}

                                                                                                                                                                                      # Creates a VNIC for the firewall's untrust interface
resource "oci_core_vnic_attachment" "untrust_vnic_attachment" {
  instance_id              = oci_core_instance.firewall_instance.id                                                                                                                   # Firewall instance ID
  display_name             = local.untrust_vnic_name_prefix                                                                                                                           # Name of the untrust VNIC
  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust_subnet.id                                                                                                                        # Untrust subnet ID
    display_name           = local.untrust_vnic_name_prefix                                                                                                                           # Name of the untrust VNIC
    assign_public_ip       = true                                                                                                                                                     # Assign a public IP to the untrust VNIC
    private_ip             = "10.1.2.10"                                                                                                                                              # Static IP for untrust interface
  }
}

                                                                                                                                                                                      # Fetches the VNIC details for the untrust interface
data "oci_core_vnic" "untrust_vnic" {
  vnic_id                  = oci_core_vnic_attachment.untrust_vnic_attachment.vnic_id                                                                                                 # Untrust VNIC ID
}

                                                                                                                                                                                      # Fetches the public IP associated with the untrust VNIC
data "oci_core_public_ip" "untrust_public_ip" {
  ip_address               = data.oci_core_vnic.untrust_vnic.public_ip_address                                                                                                        # Public IP address of the untrust VNIC
}

                                                                                                                                                                                      # Outputs the private IP of the firewall's trust interface
output "firewall_trust_private_ip" {
  value                    = "10.1.1.10"                                                                                                                                              # Static private IP of the trust interface
  description              = "Private IP of the firewall trust interface"
}

                                                                                                                                                                                      # Outputs the private IP of the firewall's untrust interface
output "firewall_untrust_private_ip" {
  value                    = "10.1.2.10"                                                                                                                                              # Static private IP of the untrust interface
  description              = "Private IP of the untrust interface"
}

                                                                                                                                                                                      # Outputs the public IP of the firewall's untrust interface
output "firewall_untrust_public_ip" {
  value                    = data.oci_core_public_ip.untrust_public_ip.ip_address                                                                                                     # Public IP of the untrust interface
  description              = "Public IP of the firewall untrust interface"
}

                                                                                                                                                                                      # Outputs the public IP of the firewall's management interface (primary VNIC)
output "firewall_mgmt_public_ip" {
  value                    = oci_core_instance.firewall_instance.public_ip                                                                                                            # Public IP of the management interface
  description              = "Public IP of the firewall management interface"
}

resource "oci_core_app_catalog_subscription" "generated_oci_core_app_catalog_subscription" {
  compartment_id           = var.compartment_ocid                                                                                                                                     # Compartment for the subscription
  eula_link                = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.eula_link}"                 # EULA link for the image
  listing_id               = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.listing_id}"                # Listing ID for the image
  listing_resource_version = "10.1.14-h9"                                                                                                                                             # Version of the image to subscribe to
  oracle_terms_of_use_link = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.oracle_terms_of_use_link}"  # Oracle terms of use link
  signature                = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.signature}"                 # Signature for the agreement
  time_retrieved           = "${oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.time_retrieved}"            # Time the agreement was retrieved
}

resource "oci_core_app_catalog_listing_resource_version_agreement" "generated_oci_core_app_catalog_listing_resource_version_agreement" {
  listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaai7wszf2tvojm2zw5epmx6ynaivbbe6zpye2kts344zg6u2jujbta"                                                              # Listing ID for the Palo Alto image
  listing_resource_version = "10.1.14-h9"                                                                                                                                             # Version of the Palo Alto image
}