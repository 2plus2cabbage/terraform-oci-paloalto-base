                                                                                                                                           # Defines variables for OCI project configuration
variable "tenancy_ocid" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "OCI tenancy OCID for authentication"                                                                                  # OCI tenancy identifier
}

variable "user_ocid" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "OCI user OCID for authentication"                                                                                     # OCI user identifier
}

variable "fingerprint" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "Fingerprint of the API key for authentication"                                                                        # API key fingerprint
}

variable "private_key_path" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "Path to the private key file for authentication"                                                                      # File path to private API key
}

variable "compartment_ocid" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "OCI compartment OCID for resource deployment"                                                                         # Compartment identifier
}

variable "region" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "OCI region for resource deployment"                                                                                   # Geographic region for deployment
}

variable "environment_name" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "Environment identifier used in resource naming"                                                                       # Environment name for naming conventions
}

variable "location" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "Location identifier used in resource naming"                                                                          # Location abbreviation for naming conventions
}

variable "my_public_ip" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "Your public IP in CIDR format for management access"                                                                  # Public IP address with CIDR notation
  
  validation {
    condition     = can(cidrhost(var.my_public_ip, 0))                                                                                     # Validates CIDR notation format
    error_message = "Must be a valid CIDR notation (e.g., 203.0.113.5/32)"                                                                 # Error message for invalid CIDR
  }
}

variable "firewall_image_ocid" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "OCID of the Palo Alto VM-Series image from OCI Marketplace"                                                           # Marketplace image identifier
}

variable "ssh_public_key" {
  type            = string                                                                                                                 # Data type for the variable
  description     = "SSH public key for firewall admin authentication"                                                                     # SSH public key for admin access
  
  validation {
    condition     = can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ", var.ssh_public_key))  # Validates SSH key format
    error_message = "Must be a valid SSH public key starting with ssh-rsa, ssh-ed25519, or ecdsa-sha2-*"                                   # Error message for invalid key
  }
}