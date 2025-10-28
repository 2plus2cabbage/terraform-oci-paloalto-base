                                                                                         # Defines the Terraform provider and version requirements for the OCI deployment
terraform {
  required_providers {
    oci       = {
      source  = "hashicorp/oci"                                                          # Official Oracle Cloud Infrastructure provider source
      version = ">= 5.38.0"                                                              # Minimum provider version required
    }
  }
}