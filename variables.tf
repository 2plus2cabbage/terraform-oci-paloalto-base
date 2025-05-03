# Defines variables for OCI project configuration
variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID, found in OCI Console under Profile"
}

variable "user_ocid" {
  type        = string
  description = "OCI user OCID, found in OCI Console under Profile"
}

variable "fingerprint" {
  type        = string
  description = "Fingerprint of the API key, found in OCI Console under Profile > API Keys"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key file for the API key"
}

variable "compartment_ocid" {
  type        = string
  description = "OCI compartment ID, found in OCI Console under Identity > Compartments"
}

variable "region" {
  type        = string
  description = "OCI region for deployment"
}

variable "environment_name" {
  type        = string
  description = "Name for your environment, used in resource naming"
}

variable "location" {
  type        = string
  description = "Location identifier, used in resource naming"
}

variable "my_public_ip" {
  type        = string
  description = "Your public IP for RDP, SSL, and SSH access"
}

variable "firewall_image_ocid" {
  type        = string
  description = "OCID of the Palo Alto Networks VM-Series image from the OCI Marketplace"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for firewall admin user login"
}