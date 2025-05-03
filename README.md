<img align="right" width="150" src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/2plus2cabbage.png">

<img src="https://github.com/2plus2cabbage/2plus2cabbage/blob/main/images/oci-base.png" alt="oci-base" width="300" align="left">
<br clear="left">

# OCI Firewall and Windows Server Terraform Deployment

Deploys a Palo Alto firewall and a Windows Server 2022 instance in Oracle Cloud Infrastructure (OCI). The firewall has three interfaces - management, trust, and untrust. The Windows Server is in the trust subnet and accesses the internet through the firewall.

## Files
The project is split into multiple files to illustrate modularity and keep separate constructs distinct, making it easier to manage and understand.
- `ociprovider.tf`: Configures the OCI provider.
- `main.tf`: Defines Terraform provider requirements.
- `locals.tf`: Defines naming prefixes for resources.
- `variables.tf`: Defines input variables.
- `terraform.tfvars`: Contains variable values (update with your details).
- `oci-networking.tf`: Sets up VCN, subnets, and gateways.
- `routing-static.tf`: Configures route tables.
- `securitylist.tf`: Defines security rules for subnets.
- `firewall.tf`: Deploys the Palo Alto firewall with management, trust, and untrust interfaces.
- `windows.tf`: Deploys the Windows Server in the trust subnet.

## How It Works
- **Networking**: VCN and subnets provide connectivity. Internet gateway and route tables enable inbound/outbound traffic.
- **Security**: Allows SSH/HTTPS to the firewall management interface from your IP, all inbound traffic to the untrust and trust interfaces (firewall-controlled), and all outbound traffic.
- **Firewall**: Configured with management (MGT), trust (ethernet1/1), and untrust (ethernet1/2) interfaces.
- **Instance**: Windows Server 2022 VM in the trust subnet with no public IP, firewall disabled via `user_data`.

## Prerequisites
- An OCI account with a compartment.
- An API key pair with noted `tenancy_ocid`, `user_ocid`, `fingerprint`, `private_key_path`, `region`.
- Terraform installed on your machine.
- Examples are demonstrated using Visual Studio Code (VSCode).
- SSH key pair for firewall access.

## Deployment Steps
1. Clone the repository.
2. Update `terraform.tfvars` with OCI credentials, firewall image OCID, SSH public key, and your public IP in `my_public_ip`.
3. Run `terraform init`, then (optionally) `terraform plan` to preview changes, then `terraform apply` (type `yes`).
4. Get the management public IP from the `firewall_mgmt_public_ip` output on the screen, or run `terraform output firewall_mgmt_public_ip`, or check in the OCI Console under **Compute > Instances**.
5. SSH to the firewall management interface using `ssh -i <private-key-file> admin@<firewall_mgmt_public_ip>`, then change the admin password for GUI access: enter configuration mode with `configure`, set password with `set mgt-config users admin password`, commit with `commit`, and exit with `exit`.
6. Update `MY-PUBLIC-IP` in `firewall-config.xml`: find and replace `5.5.5.5/32` with your actual public IP (same as `my_public_ip` in `terraform.tfvars`), then save the file.
7. Import the XML configuration via the GUI at `https://<firewall_mgmt_public_ip>`: log in with username `admin` and the password set in Step 5, go to **Device > Setup > Operations > Import Named Configuration Snapshot**, upload your XML file, load, and commit (note that after the commit, the admin password will be reset to `2Plus2cabbage!`).
8. Access the Windows Server via RDP: ensure your XML configuration includes a NAT rule to forward RDP to `10.1.1.20`, use the untrust public IP (`terraform output firewall_untrust_public_ip`), username `opc`, and initial password from OCI Console (**Compute > Instances > [select instance] > Resources > Instance Access > Show Initial Password**).
9. Verify connectivity from the Windows Server: open Command Prompt or PowerShell, test internet access with `ping google.com`, confirm connectivity is successful.
10. To remove all resources, run `terraform destroy` (type `yes`).

## Potential costs and licensing
- The resources deployed using this Terraform configuration should generally incur minimal to no costs, provided they are terminated promptly after creation.
- It is important to fully understand your cloud provider's billing structure, trial periods, and any potential costs associated with the deployment of resources in public cloud environments.
- You are also responsible for any applicable software licensing or other charges that may arise from the deployment and usage of these resources.