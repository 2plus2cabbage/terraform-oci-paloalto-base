                                                                                                                                                                                # Data source to automatically get the first available availability domain in the region
data "oci_identity_availability_domains" "ads" {
  compartment_id           = var.compartment_ocid                                                                                                                               # Compartment to query for availability domains
}

                                                                                                                                                                                # Creates the Palo Alto firewall instance with the primary VNIC in the management subnet
resource "oci_core_instance" "firewall_instance" {
  availability_domain      = data.oci_identity_availability_domains.ads.availability_domains[0].name                                                                            # Uses first available AD in the region
  compartment_id           = var.compartment_ocid                                                                                                                               # Compartment for the firewall instance
  shape                    = "VM.Standard3.Flex"                                                                                                                                # Flexible VM shape for the firewall
  shape_config {
    ocpus                  = 3                                                                                                                                                  # Number of OCPUs allocated to the instance
    memory_in_gbs          = 42                                                                                                                                                 # Memory in GB allocated to the instance
  }
  display_name             = "${local.firewall_name_prefix}-001"                                                                                                                # Name of the firewall instance using local prefix
  source_details {
    source_type            = "image"                                                                                                                                            # Instance created from an image
    source_id              = var.firewall_image_ocid                                                                                                                            # Palo Alto firewall image OCID from Marketplace
  }
  create_vnic_details {
    subnet_id              = oci_core_subnet.mgmt_subnet.id                                                                                                                     # Primary VNIC attached to management subnet
    display_name           = local.mgmt_vnic_name_prefix                                                                                                                        # Name of the management VNIC
    assign_public_ip       = true                                                                                                                                               # Assigns ephemeral public IP for management access
  }
  metadata                 = {
    ssh_authorized_keys    = var.ssh_public_key                                                                                                                                 # SSH public key for admin authentication
  }
}

                                                                                                                                                                                # Creates a VNIC attachment for the firewall's trust interface
resource "oci_core_vnic_attachment" "trust_vnic_attachment" {
  instance_id              = oci_core_instance.firewall_instance.id                                                                                                             # Firewall instance to attach VNIC to
  display_name             = local.trust_vnic_name_prefix                                                                                                                       # Name of the trust VNIC attachment
  create_vnic_details {
    subnet_id              = oci_core_subnet.trust_subnet.id                                                                                                                    # Trust subnet for internal traffic
    display_name           = local.trust_vnic_name_prefix                                                                                                                       # Name of the trust VNIC
    assign_public_ip       = false                                                                                                                                              # No public IP needed for internal interface
    private_ip             = "10.1.1.10"                                                                                                                                        # Static private IP for trust interface
    skip_source_dest_check = true                                                                                                                                               # Disables source/destination check for routing
  }
}

                                                                                                                                                                                # Fetches the private IP details for the trust VNIC to use in routing
data "oci_core_private_ips" "trust_private_ips" {
  vnic_id                  = oci_core_vnic_attachment.trust_vnic_attachment.vnic_id                                                                                             # Trust VNIC ID to query
}

                                                                                                                                                                                # Creates a VNIC attachment for the firewall's untrust interface
resource "oci_core_vnic_attachment" "untrust_vnic_attachment" {
  instance_id              = oci_core_instance.firewall_instance.id                                                                                                             # Firewall instance to attach VNIC to
  display_name             = local.untrust_vnic_name_prefix                                                                                                                     # Name of the untrust VNIC attachment
  create_vnic_details {
    subnet_id              = oci_core_subnet.untrust_subnet.id                                                                                                                  # Untrust subnet for external traffic
    display_name           = local.untrust_vnic_name_prefix                                                                                                                     # Name of the untrust VNIC
    assign_public_ip       = true                                                                                                                                               # Assigns public IP for internet connectivity
    private_ip             = "10.1.2.10"                                                                                                                                        # Static private IP for untrust interface
  }
}

                                                                                                                                                                                # Fetches the VNIC details for the untrust interface to retrieve public IP
data "oci_core_vnic" "untrust_vnic" {
  vnic_id                  = oci_core_vnic_attachment.untrust_vnic_attachment.vnic_id                                                                                           # Untrust VNIC ID to query
}

                                                                                                                                                                                # Fetches the public IP object associated with the untrust VNIC
data "oci_core_public_ip" "untrust_public_ip" {
  ip_address               = data.oci_core_vnic.untrust_vnic.public_ip_address                                                                                                  # Public IP address of untrust interface
}

                                                                                                                                                                                # Subscribes to the Palo Alto VM-Series image in the OCI Marketplace
resource "oci_core_app_catalog_subscription" "generated_oci_core_app_catalog_subscription" {
  compartment_id           = var.compartment_ocid                                                                                                                               # Compartment for the subscription
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.eula_link                # EULA acceptance link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.listing_id               # Marketplace listing ID
  listing_resource_version = "10.1.14-h9"                                                                                                                                       # Specific tested Palo Alto image version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.oracle_terms_of_use_link # Oracle terms link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.signature                # Agreement signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.generated_oci_core_app_catalog_listing_resource_version_agreement.time_retrieved           # Agreement retrieval timestamp
}

                                                                                                                                                                                # Accepts the terms and conditions for the Palo Alto VM-Series Marketplace image
resource "oci_core_app_catalog_listing_resource_version_agreement" "generated_oci_core_app_catalog_listing_resource_version_agreement" {
  listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaai7wszf2tvojm2zw5epmx6ynaivbbe6zpye2kts344zg6u2jujbta"                                                        # Palo Alto VM-Series Marketplace listing OCID
  listing_resource_version = "10.1.14-h9"                                                                                                                                       # Specific tested Palo Alto image version
}

                                                                                                                                                                                # Outputs the private IP of the firewall trust interface
output "firewall_trust_private_ip" {
  value                    = "10.1.1.10"                                                                                                                                        # Static private IP of trust interface
  description              = "Private IP of the firewall trust interface"
}

                                                                                                                                                                                # Outputs the private IP of the firewall untrust interface
output "firewall_untrust_private_ip" {
  value                    = "10.1.2.10"                                                                                                                                        # Static private IP of untrust interface
  description              = "Private IP of the untrust interface"
}

                                                                                                                                                                                # Outputs the public IP of the firewall untrust interface
output "firewall_untrust_public_ip" {
  value                    = data.oci_core_public_ip.untrust_public_ip.ip_address                                                                                               # Public IP for external connectivity
  description              = "Public IP of the firewall untrust interface"
}

                                                                                                                                                                                # Outputs the public IP of the firewall management interface
output "firewall_mgmt_public_ip" {
  value                    = oci_core_instance.firewall_instance.public_ip                                                                                                      # Public IP for management access
  description              = "Public IP of the firewall management interface"
}