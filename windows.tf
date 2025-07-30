                                                                                                                        # Creates a Windows Server 2022 VM instance in OCI
resource "oci_core_instance" "windows_instance" {
  availability_domain        = "reie:US-ASHBURN-AD-1"                                                                   # Availability domain for the VM
  compartment_id             = var.compartment_ocid                                                                     # Compartment for the VM
  shape                      = "VM.Standard.E2.1"                                                                       # VM shape (compute resources)
  display_name               = "${local.windows_name_prefix}001"                                                        # Name of the VM
  source_details {
    source_type              = "image"                                                                                  # Source type for the VM
    source_id                = "ocid1.image.oc1.iad.aaaaaaaab4ql4h3nbubj6sapv526y6cnteiglv7vffesqujwd6uszjwyrzlq"       # Windows Server 2022 image ID
  }
  create_vnic_details {
    subnet_id                = oci_core_subnet.trust_subnet.id                                                          # Subnet for the VM's network interface
    assign_public_ip         = false                                                                                    # No public IP for trust subnet VNIC
    private_ip               = "10.1.1.20"                                                                              # Static IP for Windows VM
  }
  metadata                   = {
    user_data                = base64encode("powershell.exe -Command \"netsh advfirewall set allprofiles state off\"")  # Disables firewall on boot
  }
}

                                                                                                                        # Outputs the private IP of the Windows VM for internal networking
output "oci_vm_private_ip" {
  value                      = oci_core_instance.windows_instance.private_ip
}