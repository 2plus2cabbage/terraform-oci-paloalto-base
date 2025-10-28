                                                                                                                                  # Creates a Windows Server 2022 VM instance in OCI behind the Palo Alto firewall
resource "oci_core_instance" "windows_instance" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name                                   # Uses same AD as firewall instance
  compartment_id      = var.compartment_ocid                                                                                      # Compartment for the Windows instance
  shape               = "VM.Standard.E2.1"                                                                                        # VM shape defining compute resources
  display_name        = "${local.windows_name_prefix}001"                                                                         # Name of the Windows instance using local prefix
  source_details {
    source_type       = "image"                                                                                                   # Instance created from an image
    source_id         = "ocid1.image.oc1.iad.aaaaaaaab4ql4h3nbubj6sapv526y6cnteiglv7vffesqujwd6uszjwyrzlq"                        # Windows Server 2022 image OCID for us-ashburn-1
  }
  create_vnic_details {
    subnet_id         = oci_core_subnet.trust_subnet.id                                                                           # Connects VM to trust subnet behind firewall
    assign_public_ip  = false                                                                                                     # No public IP for trust subnet instances
    private_ip        = "10.1.1.20"                                                                                               # Static private IP address for the VM
  }
  metadata            = {
    user_data         = base64encode("powershell.exe -Command \"netsh advfirewall set allprofiles state off\"")                   # Disables Windows firewall on first boot
  }
}

                                                                                                                                  # Outputs the private IP of the Windows VM
output "oci_vm_private_ip" {
  value               = oci_core_instance.windows_instance.private_ip                                                             # Private IP address of the Windows instance
  description         = "Private IP of the Windows VM in the trust subnet"                                                        # Description of the output value
}