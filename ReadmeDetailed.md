# Detailed Deployment Guide: OCI Firewall and Windows Server Terraform Deployment

This guide provides step-by-step instructions to deploy a Palo Alto firewall and a Windows Server 2022 VM in Oracle Cloud Infrastructure (OCI) using Terraform. The firewall is configured with three interfaces (management, trust, untrust), and the Windows Server is placed in the trust subnet with internet access controlled by the firewall.

## Prerequisites
Before starting, ensure you have the following:
- An OCI account with a compartment where you have permission to create resources.
- An API key pair generated in OCI Console under **Profile > API Keys**, with noted `tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path` (path to the private key file), and `region` (e.g., `us-ashburn-1`).
- Terraform installed on your machine (version compatible with the `hashicorp/oci` provider, e.g., Terraform 1.5.x).
- Visual Studio Code (VSCode) or another editor for modifying files.
- Your public IP address for SSH/HTTPS access to the firewall (e.g., `203.0.113.5/32`; find it using a service like `whatismyipaddress.com`).
- SSH key pair for firewall access; generate with `ssh-keygen -t rsa -b 4096 -C "admin@firewall" -f palo_alto_key`.
- A Palo Alto firewall XML configuration file (e.g., `firewall-config.xml`) ready for manual import.
- Note: Cloud providers regularly change their console interfaces without notice. Steps outlined today may not apply exactly tomorrow.

## Deployment Steps

### Step 1: Update terraform.tfvars with OCI Credentials and Configuration
1. Open the `terraform.tfvars` file in your editor (e.g., VSCode).
2. Update the following fields with your information:
   - `tenancy_ocid`: Replace `"<your-tenancy-ocid>"` with your OCI tenancy OCID (e.g., `ocid1.tenancy...`).
   - `user_ocid`: Replace `"<your-user-ocid>"` with your OCI user OCID (e.g., `ocid1.user...`).
   - `fingerprint`: Replace `"<your-fingerprint>"` with the fingerprint of your API key (e.g., `12:34:56...`).
   - `private_key_path`: Replace `"<path-to-private-key>"` with the local path to your private key file (e.g., `/path/to/private-key.pem`).
   - `compartment_ocid`: Replace `"<your-compartment-id>"` with your OCI compartment OCID (e.g., `ocid1.compartment...`).
   - `region`: Replace `"<your-region>"` with your OCI region (e.g., `us-ashburn-1`).
   - `environment_name`: Replace `"<your-environment-name>"` with your environment name (e.g., `cabbage`).
   - `location`: Replace `"<your-location>"` with your location identifier (e.g., `usashburn`).
   - `my_public_ip`: Replace `"<your-public-ip>"` with your public IP for SSH/HTTPS access (e.g., `203.0.113.5/32`).
   - `firewall_image_ocid`: Replace `"<your-firewall-image-ocid>"` with the Palo Alto VM-Series image OCID from OCI Marketplace (e.g., `ocid1.image...`).
   - `ssh_public_key`: Replace `"<your-ssh-public-key>"` with your SSH public key (e.g., content of `palo_alto_key.pub`, such as `ssh-rsa AAAAB3NzaC1yc2E...`).
3. Save the file.

### Step 2: Initialize and Deploy the OCI Project
1. Open a terminal in the project directory.
2. Run `terraform init` to initialize the Terraform working directory and download providers. This should take about 30 seconds.
3. (Optional) Run `terraform plan` to preview the changes Terraform will make. Review the output to ensure it looks correct (should take 15-30 seconds).
4. Run `terraform apply` to deploy the OCI resources. Type `yes` when prompted to confirm. This will create the VCN, subnets, firewall, and Windows Server (takes about 5-10 minutes).

### Step 3: Retrieve the Firewall Public IPs
1. After deployment, Terraform will output several values. Note the following:
   - `firewall_mgmt_public_ip`: Public IP of the firewall’s management interface (e.g., `129.213.45.67`) for SSH access.
   - `firewall_untrust_public_ip`: Public IP of the firewall’s untrust interface (e.g., `150.136.200.108`) for potential NAT setup.
2. Alternatively, find the public IPs in the OCI Console:
   - Go to **Compute > Instances**.
   - Locate the instance named `fw-<environment_name>-<location>-001` (e.g., `fw-cabbage-usashburn-001`).
   - Note the "Public IP" in the details pane for the management interface.
   - Under **Resources > Attached VNICs**, find the untrust VNIC (`vnic-<environment_name>-<location>-untrust`) and note its public IP.

### Step 4: Manually Associate the Trust Route Table
1. Go to the OCI Console: **Networking > Virtual Cloud Networks**.
2. Select your VCN (`vcn-<environment_name>-<location>-001`, e.g., `vcn-cabbage-usashburn-001`).
3. Under **Resources**, select **Subnets**, then click on the trust subnet (`snet-<environment_name>-<location>-trust-001`, e.g., `snet-cabbage-usashburn-trust-001`).
4. Click **Edit**, then under **Route Table**, select the trust route table (`rt-<environment_name>-<location>-trust-001`, e.g., `rt-cabbage-usashburn-trust-001`).
5. Save changes to route trust subnet traffic through the firewall’s trust interface (`10.1.1.10`).

### Step 5: SSH to the Firewall Management Interface and Change Admin Password
1. Open a terminal on your machine.
2. Use the SSH key and management public IP to connect: `ssh -i <private-key-file> admin@<firewall_mgmt_public_ip>` (e.g., `ssh -i palo_alto_key admin@129.213.45.67`).
3. You should now be logged into the firewall CLI as the `admin` user.
4. Enter configuration mode: `configure`.
5. Change the admin password for GUI access: `set mgt-config users admin password`.
6. Enter a new password when prompted, then confirm it.
7. Commit the change: `commit`.
8. Exit configuration mode: `exit`.

### Step 6: Update MY-PUBLIC-IP in the XML Configuration File
1. Open the `firewall-config.xml` file in your editor (e.g., VSCode).
2. Find and replace the placeholder IP `5.5.5.5/32` with your actual public IP (the same value used for `my_public_ip` in `terraform.tfvars`, e.g., `203.0.113.5/32`).
   - Search for `<ip-netmask>5.5.5.5/32</ip-netmask>` under the `MY-PUBLIC-IP` address entry.
   - Replace it with `<ip-netmask>YOUR_PUBLIC_IP/32</ip-netmask>` (e.g., `<ip-netmask>203.0.113.5/32</ip-netmask>`).
3. Save the file.

### Step 7: Import the XML Configuration to the Firewall via GUI
1. Access the firewall GUI via HTTPS: `https://<firewall_mgmt_public_ip>` in your browser (e.g., `https://129.213.45.67`).
2. Log in with username `admin` and the password you set in Step 5.
3. Go to **Device > Setup > Operations > Import Named Configuration Snapshot**.
4. Click **Choose File**, select your updated XML configuration file (e.g., `firewall-config.xml`), and click **OK**.
5. Click **Load** to apply the configuration.
6. Click **Commit** in the top-right corner to save the changes. Note that after the commit, the admin password will be reset to `2Plus2cabbage!` due to the imported XML configuration.

### Step 8: Access the Windows Server via RDP
1. Ensure your XML configuration in Step 7 includes a NAT rule to forward RDP traffic to the Windows Server (e.g., source `any`, destination `<firewall_untrust_public_ip>`, service RDP TCP 3389, translated destination `10.1.1.20`).
2. Open your Remote Desktop client (e.g., Microsoft Remote Desktop).
3. Enter the firewall’s untrust public IP (`terraform output firewall_untrust_public_ip`, e.g., `150.136.200.108`).
4. Use the username `opc` and the initial password (find in OCI Console under **Compute > Instances > [select instance vm-<environment_name>-<location>-windows001] > Resources > Instance Access > Show Initial Password**).
5. Connect to the VM.

### Step 9: Verify Connectivity from the Windows Server
1. From the Windows Server, open Command Prompt or PowerShell.
2. Test internet access: `ping google.com`.
3. Confirm connectivity is successful, indicating the firewall policies are working.

### Step 10: Clean Up Resources
1. Reset the trust subnet route table to default in the OCI Console to ensure Terraform can destroy the project (Terraform will fail if the manual change from Step 4 is left in place):
   - Go to **Networking > Virtual Cloud Networks**.
   - Select your VCN (`vcn-<environment_name>-<location>-001`, e.g., `vcn-cabbage-usashburn-001`).
   - Under **Resources**, select **Subnets**, then click on the trust subnet (`snet-<environment_name>-<location>-trust-001`, e.g., `snet-cabbage-usashburn-trust-001`).
   - Click **Edit**, then under **Route Table**, select the default route table for the VCN (named `Default Route Table for vcn-<environment_name>-<location>-001`, e.g., `Default Route Table for vcn-cabbage-usashburn-001`).
   - Save changes to remove the association with the trust route table.
2. In the terminal, run `terraform destroy` to remove all resources. Type `yes` to confirm (takes about 2-5 minutes).
3. Verify in the OCI Console that all resources (VCN, subnets, instances) are deleted.

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation; the firewall instance (VM.Standard3.Flex, 3 OCPUs, 42 GB memory) and Windows Server (VM.Standard.E2.1) may incur compute and storage charges.
- It is important to understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments; check OCI pricing for compute instances and Marketplace images.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources, including Palo Alto licensing for the VM-Series firewall and Windows Server licensing.