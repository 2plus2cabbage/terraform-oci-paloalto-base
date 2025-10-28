                                                                                         # Configures the OCI provider with authentication details for Terraform to manage OCI resources
provider "oci" {
  tenancy_ocid     = var.tenancy_ocid                                                    # OCI tenancy identifier for authentication
  user_ocid        = var.user_ocid                                                       # OCI user identifier for authentication
  fingerprint      = var.fingerprint                                                     # API key fingerprint for authentication
  private_key_path = var.private_key_path                                                # Path to private API key file for authentication
  region           = var.region                                                          # OCI region for resource deployment
}