<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/oci-paloalto-base.png" alt="oci-paloalto-base" width="300" align="left">
<br clear="left">

# OCI Palo Alto VM-Series Firewall with Windows Instance

Deploys a Palo Alto VM-Series firewall in Oracle Cloud Infrastructure (OCI) with three network interfaces (management, untrust, and trust), along with a Windows Server 2022 VM behind the firewall for testing.

## Architecture Overview
This deployment creates a standard three-interface Palo Alto firewall topology:
- **Management Subnet (10.1.3.0/24)**: Dedicated subnet for firewall management access via SSH and HTTPS
- **Untrust Subnet (10.1.2.0/24)**: External-facing subnet for internet traffic
- **Trust Subnet (10.1.1.0/24)**: Internal subnet where protected resources reside (includes Windows VM)
- All traffic from the trust subnet is routed through the Palo Alto firewall trust interface

## Files
The project is split into multiple files to illustrate modularity and keep separate constructs distinct, making it easier to manage and understand.
- `main.tf`: Terraform provider block (hashicorp/oci).
- `oci-provider.tf`: OCI provider config with tenancy_ocid, user_ocid, and authentication credentials.
- `variables.tf`: Variable definitions for tenancy, compartment, region, IP addresses, and SSH keys.
- `terraform.tfvars.template`: Template for sensitive/custom values; rename to terraform.tfvars and add your credentials.
- `locals.tf`: Local variables for consistent resource naming conventions across the deployment.
- `oci-networking.tf`: VCN with three subnets (mgmt, untrust, trust) and Internet Gateway.
- `securitylist.tf`: OCI security lists that allow the Palo Alto firewall to control all security policies. Rules are intentionally permissive since the Palo Alto instance handles security enforcement.
- `routing-static.tf`: Route tables including default internet gateway routes for management and untrust subnets, and a route directing all trust traffic through the Palo Alto firewall.
- `firewall.tf`: Palo Alto VM-Series firewall instance with three VNICs, marketplace subscription, and SSH key authentication.
- `windows.tf`: Windows Server 2022 VM in the trust subnet for testing firewall functionality.

## How It Works
- **Networking**: Single VCN with three dedicated subnets provides network segmentation. Each subnet has its own routing and security configuration.
- **Security**: OCI security lists are intentionally permissive to allow the Palo Alto firewall to enforce all security policies. Management interface access is restricted to your public IP address.
- **Routing**: Trust subnet traffic is directed through the Palo Alto firewall (10.1.1.10), which acts as the next hop for internet-bound traffic.
- **Instances**: 
  - Palo Alto VM-Series firewall with three VNICs (management, untrust, trust)
  - Windows Server 2022 VM behind the firewall in the trust subnet
- **Authentication**: SSH access to the Palo Alto firewall uses public key authentication configured via instance metadata.
- **Availability**: Availability domain is automatically selected (first available AD in the region).

## Prerequisites
- An OCI account with a compartment.
- API key pair configured with tenancy_ocid, user_ocid, fingerprint, private_key_path, and region noted.
- Terraform installed on your machine.
- An SSH key pair for Palo Alto firewall access (see SSH Key Setup below).
- Examples are demonstrated using Visual Studio Code (VSCode).

## SSH Key Setup
Before deployment, generate an SSH key pair for Palo Alto firewall access:

**Generate a new SSH key pair:**
```
ssh-keygen -t rsa -b 4096 -C "palo-admin" -f ~/.ssh/palo_alto_key
```

This creates two files:
- `palo_alto_key` (private key - keep secure)
- `palo_alto_key.pub` (public key - used in Terraform)

Ensure your public key is in OpenSSH format (single line starting with `ssh-rsa`). If you have an SSH2 RFC4716 format key (with `BEGIN SSH2 PUBLIC KEY` headers), convert it:

```
ssh-keygen -i -f your_key.pub > your_key_openssh.pub
```

## Deployment Steps
1. Copy `terraform.tfvars.template` to `terraform.tfvars` and update with your values:
   - `tenancy_ocid`: Your OCI tenancy OCID
   - `user_ocid`: Your OCI user OCID
   - `fingerprint`: Your API key fingerprint
   - `private_key_path`: Path to your API private key file
   - `compartment_ocid`: Your OCI compartment OCID
   - `region`: Your preferred OCI region (e.g., us-ashburn-1)
   - `environment_name`: Environment identifier (e.g., dev, test, prod)
   - `location`: Location abbreviation (e.g., usashburn)
   - `my_public_ip`: Your public IP in CIDR format (e.g., 1.2.3.4/32) for management access
   - `firewall_image_ocid`: Palo Alto VM-Series image OCID (pre-filled for us-ashburn-1)
   - `ssh_public_key`: Your SSH public key content (paste the entire key)

2. Run `terraform init` to initialize the Terraform working directory and download required providers.

3. (Optional) Run `terraform plan` to preview the resources that will be created.

4. Run `terraform apply` and type `yes` when prompted to create the resources.

5. After deployment completes, note the output values:
   - `firewall_mgmt_public_ip`: Public IP for SSH and HTTPS access to firewall management
   - `firewall_untrust_public_ip`: Public IP of the untrust interface
   - `firewall_trust_private_ip`: Private IP of the trust interface (10.1.1.10)
   - `oci_vm_private_ip`: Private IP of the Windows VM (10.1.1.20)

6. **Prepare the firewall configuration file**:
   - Update `MY-PUBLIC-IP` in `firewall-config.xml`: find and replace `5.5.5.5/32` with your actual public IP (same as `my_public_ip` in `terraform.tfvars`), then save the file.

7. **Access the Palo Alto Firewall**:
   - Via SSH: `ssh -i ~/.ssh/palo_alto_key admin@<firewall_mgmt_public_ip>`
   - Set a new admin password from SSH:
   ```
   configure
   set mgt-config users admin password
   ```
   Enter new password when prompted (twice for confirmation)
   ```
   commit
   exit
   ```
   - Via Web UI: Open `https://<firewall_mgmt_public_ip>` in a browser and log in with username `admin` and the password you just set

8. **Import the firewall configuration**:
   - In the web UI, go to **Device > Setup > Operations > Import Named Configuration Snapshot**
   - Upload your `firewall-config.xml` file
   - Go to **Device > Setup > Operations > Load Named Configuration Snapshot**
   - Select the imported file to load the configuration
   - Click **Commit** to apply the configuration
   - Note: After the commit, the admin username will be changed to `fwadmin` and the password will be reset to `2Plus2cabbage!`

9. **Access the Windows VM**:
   - Use Remote Desktop to connect to the **untrust public IP** of the firewall (from `firewall_untrust_public_ip` output or run `terraform output firewall_untrust_public_ip`)
   - In the OCI Console, go to **Compute > Instances > [click Windows instance]**
   - On the **Details** tab, scroll down to **Instance Access**
   - Click the **...** (three dots) next to **Initial Password** and select **Show** to retrieve the password
   - Username is `opc`
   - Use this username and password to log in via RDP through the firewall's untrust interface

10. **Verify connectivity from the Windows VM**:
   - Open Command Prompt or PowerShell
   - Test internet access with `ping google.com`
   - Confirm connectivity is successful through the Palo Alto firewall

11. To remove all resources:
   - **First, revert the trust subnet route table** to prevent destroy errors:
     - In the OCI Console, go to **Networking > Virtual Cloud Networks > [your VCN] > Subnets > [trust subnet]**
     - Click **Edit**
     - Change the **Route Table** to the VCN's **Default Route Table**
     - Click **Save Changes**
   - Run `terraform destroy` and type `yes` when prompted

## Firewall Configuration Notes
- The Palo Alto firewall requires initial configuration after deployment
- SSH key authentication is configured for the admin user; no default password is set
- You must set an admin password via SSH before using the web interface (see step 7 above)
- A pre-configured `firewall-config.xml` file is included with security policies and NAT rules
- After importing and committing the XML configuration, the admin username will be changed to `fwadmin` and the password will be reset to `2Plus2cabbage!`
- The firewall uses marketplace image subscription (automatically configured by Terraform)
- Availability domain is automatically selected (first available AD in your region)

## Network Traffic Flow
1. **Outbound from Windows VM**: 
   - Traffic from Windows VM (10.1.1.20) → Trust subnet route → Palo Alto trust interface (10.1.1.10) → Palo Alto untrust interface → Internet

2. **Inbound to Windows VM**:
   - Internet → Palo Alto untrust interface → Security policies evaluated → Palo Alto trust interface → Windows VM (requires NAT and security policy configuration)

3. **Management Access**:
   - Your IP → OCI security list (restricted to your IP) → Palo Alto management interface (10.1.3.x)

## Troubleshooting
- **Cannot SSH to Palo Alto**: Verify `my_public_ip` is set correctly in CIDR format (/32)
- **SSH key authentication fails**: Ensure public key is in OpenSSH format (single line, starts with `ssh-rsa`)
- **Windows VM cannot reach internet**: Check Palo Alto firewall security policies and NAT rules
- **Terraform apply fails with image subscription errors**: Ensure you have accepted the Palo Alto Marketplace terms in OCI Console
- **Route creation fails**: The trust route uses a data source for the firewall trust interface private IP, which creates an implicit dependency
- **Terraform destroy fails**: You must revert the trust subnet route table to the default before destroying (see step 11 above)

## Potential Costs and Licensing
- **OCI Compute Costs**: 
  - Palo Alto VM-Series: VM.Standard3.Flex with 3 OCPUs and 42GB RAM
  - Windows VM: VM.Standard.E2.1 instance
  - Network egress charges apply for internet traffic
- **Palo Alto Licensing**: 
  - This deployment uses marketplace image (BYOL - Bring Your Own License)
  - You must provide your own Palo Alto VM-Series license
  - License costs vary based on throughput tier and subscriptions
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- Always run `terraform destroy` promptly after testing to avoid unnecessary charges.
- You are responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.

## Security Considerations
- This is a **teaching and testing environment** - additional hardening is recommended for production use
- Change default Palo Alto credentials immediately after first login
- Review and customize firewall security policies based on your specific requirements
- The Windows firewall is disabled by default for testing - re-enable or configure appropriately for production
- OCI security lists are permissive by design to allow Palo Alto to handle all security enforcement