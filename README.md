# Automation for the Deployment of a Disaster Recovery Protection Solution for SAP HANA 2.0 System

## Description
This automation solution is designed for the deployment of Disaster Recovery Protection solution for a non-HA **SAP HANA 2.0 System** on VSI, in a different Cloud Region than the Primary SAP HANA System. SAP HANA Secondary System will be deployed on top of one of the following Operating Systems: **SUSE Linux Enterprise Server 15 SP 4 for SAP**, **SUSE Linux Enterprise Server 15 SP 3 for SAP**, **Red Hat Enterprise Linux 8.6 for SAP**, **Red Hat Enterprise Linux 8.4 for SAP**.

The solution is based on Terraform remote-exec and Ansible playbooks and it is implementing a 'reasonable' set of best practices for SAP server host configuration.

**It contains:**
- Terraform scripts for the deployment of a VSI, in an NEW or EXISTING VPC, with Subnet, Security Group and IBM Transit Gateway. The server is intended to be used for the SAP HANA Secondary System. The automation has support for the following versions: Terraform >= 1.5.7 and IBM Cloud provider for Terraform >= 1.57.0.
- Bash scripts used for the checking of the prerequisites required by SAP server deployment and for the integration into a single step in IBM Schematics GUI of the VSI Server provisioning and the **SAP HANA DB** installation.
- Ansible scripts to configure the LVM and filesystems and the OS parameters on SAP HANA Secondary System, install SAP HANA 2.0 for the SAP HANA Secondary System and configure SAP HANA Primary and Secondary nodes for DR.
Please note that Ansible is started by Terraform and must be available on the same host.

The solution can be applied for existing SAP HANA primary systems as the ones deployed with the following automation solutions:
    https://github.com/IBM-Cloud/sap-netweaver-abap-hana
    https://github.com/IBM-Cloud/sap-netweaver-java-hana
    https://github.com/IBM-Cloud/sap-s4hana
    https://github.com/IBM-Cloud/sap-bw4hana

## Contents:

- [1.1 Installation media](#11-installation-media)
- [1.2 Server Configuration](#12-server-configuration)
- [1.3 VPC Configuration](#13-vpc-configuration)
- [1.4 Files description and structure](#14-files-description-and-structure)
- [1.5 General Input Variabiles](#15-general-input-variables)
- [2.1 Prerequisites](#21-prerequisites)
- [2.2 Executing the deployment of **Disaster Recovery Protection Solution for SAP HANA 2.0 System** in GUI (Schematics)](#22-executing-the-deployment-of-disaster-recovery-solution-for-sap-hana-2.0-system-in-gui-schematics)
- [2.3 Executing the deployment of **Disaster Recovery Protection Solution for SAP HANA 2.0 System** in CLI](#23-executing-the-deployment-of-disaster-recovery-solution-for-sap-hana-2.0-system-in-cli)
- [3.1 Related links](#31-related-links)

## 1.1 Installation media

SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS07** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided manually in the input parameter file.

## 1.2 Server Configuration

The Server is deployed with one of the following Operating Systems: **Red Hat Enterprise Linux 8.6 for SAP HANA (amd64)**, **Red Hat Enterprise Linux 8.4 for SAP HANA (amd64)**, **SUSE Linux Enterprise Server 15 SP 4 for SAP HANA (amd64)**, or **SUSE Linux Enterprise Server 15 SP 3 for SAP HANA (amd64)**. The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

SAP HANA DB Server Disks, same as on SAP HANA primary system:
- the disk sizes depend on the selected profile, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc) - Last updated 2023-12-28.

Note: For SAP HANA on a VSI, according to [Intel Virtual Server certified profiles on VPC infrastructure for SAP HANA](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc#vx2d-16x224) - Last updated 2022-01-28 and to [Storage design considerations](https://cloud.ibm.com/docs/sap?topic=sap-storage-design-considerations) - Last updated 2024-01-25, LVM will be used for **`/hana/data`**, **`hana/log`**, **`/hana/shared`** and **`/usr/sap`**, for all storage profiles, with the following exceptions:
- **`/hana/data`** and **`/hana/shared`** for the following profiles: **`vx2d-44x616`** and **`vx2d-88x1232`**
- **`/hana/shared`** for the following profiles: **`vx2d-144x2016`**, **`vx2d-176x2464`**, **`ux2d-36x1008`**, **`ux2d-48x1344`**, **`ux2d-72x2016`**, **`ux2d-100x2800`**, **`ux2d-200x5600`**.

For example, in case of deploying a SAP HANA on a VSI, using the value `mx2-16x128` for the VSI profile , the automation will execute the following storage setup:  
- 3 volumes x 500 GB each for `<sid>_hana_vg` volume group
  - the volume group will contain the following logical volumes (created with three stripes):
    - `<sid>_hana_data_lv` - size 988 GB
    - `<sid>_hana_log_lv` - size 256 GB
    - `<sid>_hana_shared` - size 256 GB
- 1 volume x 50 GB for `/usr/sap` (volume group: `<sid>_usr_sap_vg`, logical volume: `<sid>_usr_sap_lv`)
- 1 volume x 10 GB for a 2 GB SWAP logical volume (volume group: `<sid>_swap_vg`, logical volume: `<sid>_swap_lv`)

## 1.3 VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443).
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers and from Bastion to the HANA DB VSI servers.

The new Security Rules from HANA DR deployment between HANA Primary and HANA Secondary/DR Servers:
- Allow inbound SSH traffic (TCP for port 22).
- Allow inbound TCP traffic for 40000-40099 range ports.
- Allow ICMP traffic.

## 1.4 Files description and structure

 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI or Server for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI or Server is created (Hostname, Private IP)
 - `integration.tf` - contains the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `variables.tf` - contains variables for the VPC and VSI or Server
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.
 - `data.tf` - contains the data gathered from deployed resources.

## 1.5 General Input Variables

The following parameters can be set:

**IBM Cloud Resources input parameters:**

Parameter | Description
----------|------------
IBMCLOUD_API_KEY | IBM Cloud API key (Sensitive* value). The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).
SSH_KEYS | List of IBM Cloud SSH Keys UUIDs from Primary Hana Region, that are allowed to connect via SSH, as root, to the Primary SAP HANA System.  Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input:<br /> ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]
BASTION_SUBNET | The name of an EXISTING Subnet that belongs to the BASTION VSI in the same VPC where the SAP HANA Primary System is deployed. This variable is for deployment and DR purposes throught the private BASTION NETWORK ONLY. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
RESOURCE_GROUP | The name of an EXISTING Resource Group for VSI Server and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where the SAP HANA Primary System is deployed. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
VPC | The name of an EXISTING VPC where the SAP HANA Primary System is deployed. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs).
SECURITY_GROUP | The name of an EXISTING Security group for the VPC where the SAP HANA Primary System is deployed. It could be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
REGION_DR | The cloud region where to deploy the SAP HANA Secondary System. The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Sample value: eu-gb.
ZONE_DR | The cloud zone where to deploy the SAP HANA Secondary System. The available regions and zones for VPC can be found [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Sample value: eu-gb-1
VPC_DR | The name of a NEW or EXISTING VPC for the SAP HANA Secondary System, in the same region as the SAP HANA Secondary System. The list of available VPCs cane be found [here](https://cloud.ibm.com/vpc-ext/network/vpcs).
VPC_DR_EXISTS | Specifies if the VPC for DR purpose, having the provided name, already exists. Allowed values: 'yes' and 'no'. If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_DR_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS.
SUBNET_DR | The name of a NEW or EXISTING Subnet in the same VPC and same zone as SAP HANA Secondary System. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets).
SSH_KEYS_DR | List of IBM Cloud SSH Keys UUIDs from VPC DR Region, that are allowed to connect via SSH, as root, to the SAP HANA Secondary System. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]
TRANSIT_GATEWAY  | The name of a NEW or an EXISTING IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed.  The list of TRANSIT GATEWAYS is available [here](https://cloud.ibm.com/interconnectivity/transit).
TRANSIT_GATEWAY_EXISTS | Specifies if the IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed, having the provided name, already exists. Allowed values: 'yes' and 'no'. If the value 'no' is chosen, a new IBM TRANSIT GATEWAY will be created along with all needed connections. If the IBM TRANSIT GATEWAY_EXISTS is set to yes, only the connections will be created in the existing TRANSIT GATEWAY.
SUBNETS_ALREADY_ADDED_ON_TG | Specifies if the SUBNETS from the PRIMARY VPC and from DR VPC are already added to the TRANSIT GATEWAY as CONNECTONS. Allowed values: 'yes' and 'no'. If the value 'no' is chosen, the SUBNETS will be added to the IBM TRANSIT GATEWAY as new CONNECTONS.
HANA_SERVER_TYPE | The type of SAP HANA Server. Allowed vales: "virtual".
DB_HOSTNAME_PRIMARY | The Hostname of SAP HANA Primary System. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_HOSTNAME_DR | The Hostname for SAP HANA Secondary System that will be deployed in the VPC_DR. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB_PROFILE | The instance profile of SAP HANA Primary Server. The list of the certified profiles for SAP HANA on a VSI is available [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc). <br> Details about all x86 instance profiles are available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles). <br>  For more information about supported DB/OS and IBM Gen 2 Servers, check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br />
DB_IMAGE | The OS image of SAP HANA Primary Server. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-8-6-amd64-sap-hana-6


**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
HANA_MAIN_PASSWORD | Common password for all users that are created during the installation (See Obs*). | <ul><li>It must be 8 to 14 characters long</li><li>It must consist of at least one digit (0-9), one lowercase letter (a-z), and one uppercase letter (A-Z).</li><li>It can only contain the following characters: a-z, A-Z, 0-9, !, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
KIT_SAPHANA_FILE | Path to SAP HANA ZIP file (See Obs*). | As downloaded from SAP Support Portal

Parameter | Description | Requirements
----------|-------------|-------------
HANA_MAIN_PASSWORD | HANA system master password | <ul><li>It must be 8 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It must not contain \ (backslash) and " (double quote)</li><li>Master Password must contain at least one upper-case character</li></ul>

**Obs***: <br />
 - **HANA Main Password.**
The password for the HANA system (Sensitive* value) will be hidden during the schematics apply step and will not be available after the deployment.

- **Sensitive** - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITYGROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.

**Installation media validated for this solution:**

Component | Version | Filename
----------|-------------|-------------
HANA DB | 2.0 SPS07 rev73 | 51057281.ZIP

**OS images validated for this solution:**

OS version | Image | Role
-----------|-----------|-----------
Red Hat Enterprise Linux 8.6 for SAP HANA (amd64) | ibm-redhat-8-6-amd64-sap-hana-6 | DB
Red Hat Enterprise Linux 8.4 for SAP HANA (amd64) | ibm-redhat-8-4-amd64-sap-hana-10 | DB
SLES for SAP Applications 15 SP4 (amd64) | ibm-sles-15-4-amd64-sap-hana-8 | DB
SLES for SAP Applications 15 SP3 (amd64) | ibm-sles-15-3-amd64-sap-hana-11 | DB

## 2.1 Prerequisites

- An SAP HANA Primary System should exist with SAP HANA 2.0 installed.
- For SAP HANA Primary System a data backup of the SYSTEMDB and the tenant database(s) should exist
- A Deployment Server (BASTION Server) in the same VPC as SAP HANA Primary System should exist. For more information, see https://github.com/IBM-Cloud/sap-bastion-setup.
- On the Deployment Server download the SAP kits from the SAP Portal. Make note of the download locations. Ansible decompresses all of the archive kits.
- Create or retrieve an IBM Cloud API key. The API key is used to authenticate with the IBM Cloud platform and to determine your permissions for IBM Cloud services.
- Create or retrieve your SSH key ID. You need the 40-digit UUID for the SSH key, not the SSH key name.

## 2.2 Executing the deployment of **Disaster Recovery Protection Solution for SAP HANA 2.0 System** in GUI (Schematics)

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics
### Input parameters

The following parameters that can be set in the Schematics workspace are described in [General input variables Section](#15-general-input-variables) section.

Beside [General input variables Section](#15-general-input-variables), the below ones, in IBM Schematics have specific description and GUI input options:

**VSI input parameters:**

Parameter | Description
----------|------------
PRIVATE_SSH_KEY | id_rsa private SSH key content in OpenSSH format (Sensitive* value). This private SSH key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
ID_RSA_FILE_PATH | The file path for the private ssh key. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_s4hana_dst
BASTION_FLOATING_IP | The FLOATING IP of the Bastion Server in the same VPC where the SAP HANA Primary System is deployed. The FLOATING IP can be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.

**SAP HANA Main Password**  
The SAP HANA main password will be hidden during the schematics apply step and will not be available after the deployment.

### Steps to follow:

1.  Make sure that you have the [required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources) to
    create and work with VPC infrastructure and you are [assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access) to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to [upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console) in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select [Schematics](https://cloud.ibm.com/schematics/overview).
        - Push the `Create workspace` button.
        - Provide the URL of the Github repository of this solution
        - Select the latest Terraform version.
        - Click on `Next` button
        - Provide a name, the resources group and location for your workspace
        - Push `Next` button
        - Review the provided information and then push `Create` button to create your workspace
    2.  On the workspace **Settings** page, 
        - In the **Input variables** section, review the default values for the input variables and provide alternatives if desired.
        - Click **Save changes**.
4.  From the workspace **Settings** page, click **Generate plan** 
5.  From the workspace **Jobs** page, the logs of your Terraform
    execution plan can be reviewed.
6.  Apply your Terraform template by clicking **Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname, the subnet, the security group, the activity tracker name, the VPC and SAP HANA SID.

## 2.3 Executing the deployment of **Disaster Recovery Protection Solution for SAP HANA 2.0 System** in CLI

### IBM Cloud API Key
For the script configuration add your IBM Cloud API Key in terraform planning phase command 'terraform plan --out plan1'.
You can create an API Key [here](https://cloud.ibm.com/iam/apikeys).
 
### Input parameter file
The solution is configured and customized based on the input values for the variables in the file `input.auto.tfvars`
Provide your own values for VPC, Subnet, Security group, Resource Group, Hostname, Profile, Image, SSH Keys, Activity Tracker, Server Type like in the sample below:

**CLI deployment input parameters**

```shell
####################################################################
# Existing PRIMARY VPC variables before that DR Configs to take place
####################################################################

REGION = "eu-de"
# The cloud region where the SAP HANA Primary System is deployed. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations for IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations.
# Example: REGION = "eu-de"

VPC = "ic4sap"
# The name of an EXISTING VPC where the SAP HANA Primary System is deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

SECURITY_GROUP = "ic4sap-securitygroup"
# The name of an EXISTING Security group for the VPC where the SAP HANA Primary System is deployed. It could be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
# The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

BASTION_SUBNET = "ic4sap-subnet"
# The name of an EXISTING Subnet that belongs to the BASTION VSI in the same VPC where the SAP HANA Primary System is deployed. 
# This variable is for deployment and DR purposes throught the private BASTION NETWORK ONLY.
# The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = ["r010-5db21872-c98f-4945-9f69-71c637b1da50"]
# List of IBM Cloud SSH Keys UUIDs from SAP HANA Primary System Region, that are allowed to connect via SSH, as root, to the SAP HANA Primary System. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]

##########################################################
# RESOURCE GROUP for all resources
##########################################################

RESOURCE_GROUP = "wes-automation"
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

##########################################################
# id_rsa private key file path for all VSIs
##########################################################

ID_RSA_FILE_PATH = "/root/.ssh/id_rsa"
# Your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_s4hana" , "~/.ssh/id_rsa_s4hana" , "/root/.ssh/id_rsa".

##########################################################
# VPC variables for DR Site
##########################################################

REGION_DR = "eu-gb"
# The cloud region where to deploy the SAP HANA Secondary System. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations for IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations.
# Example: REGION = "eu-gb"

ZONE_DR = "eu-gb-1"
# The cloud zone where to deploy the SAP HANA Secondary System. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc.
# Example: ZONE = "eu-gb-1"

VPC_DR = "ic4sap-dr"
# The name of a NEW or EXISTING VPC for the SAP HANA Secondary System, in the same region as the SAP HANA Secondary System. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap-dr"

VPC_DR_EXISTS = "no"
# Specifies if the VPC for DR purpose, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_DR_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS.

SUBNET_DR = "ic4sap-subnetdr"
# The name of a NEW or EXISTING Subnet in the same VPC and same zone as SAP HANA Secondary System. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS_DR = ["r010-6dl2g976-c97f-7935-8dd9-72c637g1ja31"]
# List of IBM Cloud SSH Keys UUIDs from VPC DR Region, that are allowed to connect via SSH, as root, to the SAP HANA Secondary System. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-5db21872-c98f-4945-9dd69-71c637b1da50", "r010-6dl2g976-c97f-7935-8dd9-72c637g1ja31"]

##########################################################
# IBM TRANSIT GATEWAY variables
##########################################################

TRANSIT_GATEWAY = "ic4sap-tg"
# The name of a NEW or an EXISTING IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed. The list of TRANSIT GATEWAYS is available here: https://cloud.ibm.com/interconnectivity/transit.

TRANSIT_GATEWAY_EXISTS = "no"
# Specifies if the IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new IBM TRANSIT GATEWAY will be created along with all needed connections. If the IBM TRANSIT GATEWAY_EXISTS is set to yes, only the connections will be created in the existing TRANSIT GATEWAY.
# OBS. Each Subnet can be connected to only one IBM TRANSIT GATEWAY.

SUBNETS_ALREADY_ADDED_ON_TG = "no"
# Specifies if the SUBNETS from the PRIMARY VPC and from DR VPC are already added to the TRANSIT GATEWAY as CONNECTONS. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, the SUBNETS will be added to the IBM TRANSIT GATEWAY as new CONNECTONS.

##########################################################
# SAP HANA Servers variables
##########################################################

HANA_SERVER_TYPE = "virtual"
# The type of SAP HANA Server. Supported vales: "virtual".

DB_HOSTNAME_PRIMARY = "hanadb-vsi1"
# The Hostname of SAP HANA Primary System. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: Hostnames of SAP ABAP Platform servers.
# Example: DB_HOSTNAME_PRIMARY = "hanadb-vsi1"

DB_HOSTNAME_DR = "hanadb-vsi2"
# The Hostname for SAP HANA Secondary System that will be deployed in the VPC_DR. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers.
# Example: DB_HOSTNAME_DR = "hanadb-vsi2"

DB_PROFILE = "mx2-16x128"
# The instance profile of SAP HANA Primary Server.
# The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles.
# Example of Virtual Server Instance profile for SAP HANA: DB_PROFILE ="mx2-16x128". 
# For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud".

DB_IMAGE = "ibm-redhat-8-6-amd64-sap-hana-6"
# The OS image of SAP HANA Primary Server. Validated OS images for SAP HANA Server: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10, ibm-sles-15-4-amd64-sap-hana-8, ibm-sles-15-3-amd64-sap-hana-11.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-sles-15-4-amd64-sap-hana-6"

##########################################################
# SAP HANA configuration
##########################################################

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"

```

## Steps to reproduce:

For initializing terraform:

```shell
terraform init
```

For planning phase:

```shell
terraform plan --out plan1
# you will be asked for the following sensitive variables: 'IBMCLOUD_API_KEY' and 'HANA_MAIN_PASSWORD'.
```

For apply phase:

```shell
terraform apply
```

For destroy:

```shell
terraform destroy
# you will be asked for the following sensitive variables as a destroy confirmation phase:
'IBMCLOUD_API_KEY' and 'HANA_MAIN_PASSWORD'.
```

### 3.1 Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
