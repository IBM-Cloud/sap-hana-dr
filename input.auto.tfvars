####################################################################
# Existing PRIMARY VPC variables before that DR Configs to take place
####################################################################

REGION = ""
# The cloud region where the SAP HANA Primary System is deployed. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations for IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations.
# Example: REGION = "eu-de"

VPC = ""
# The name of an EXISTING VPC where the SAP HANA Primary System is deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs.
# Example: VPC = "ic4sap"

SECURITY_GROUP = ""
# The name of an EXISTING Security group for the VPC where the SAP HANA Primary System is deployed. It could be copied from the Bastion Server Deployment "OUTPUTS" at the end of "Apply plan successful" message.
# The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups.
# Example: SECURITY_GROUP = "ic4sap-securitygroup"

BASTION_SUBNET = ""
# The name of an EXISTING Subnet that belongs to the BASTION VSI in the same VPC where the SAP HANA Primary System is deployed. 
# This variable is for deployment and DR purposes throught the private BASTION NETWORK ONLY.
# The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS = [""]
# List of IBM Cloud SSH Keys UUIDs from SAP HANA Primary System Region, that are allowed to connect via SSH, as root, to the SAP HANA Primary System. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-5db21872-c98f-4945-9f69-71c637b1da50", "r010-6dl21976-c97f-7935-8dd9-72c637g1ja31"]

##########################################################
# RESOURCE GROUP for all resources
##########################################################

RESOURCE_GROUP = ""
# EXISTING Resource group, previously created by the user. The list of available Resource Groups: https://cloud.ibm.com/account/resource-groups
# Example: RESOURCE_GROUP = "wes-automation"

##########################################################
# id_rsa private key file path for all VSIs
##########################################################

ID_RSA_FILE_PATH = "ansible/id_rsa"
# Your existing id_rsa private key file path in OpenSSH format with 0600 permissions.
# This private key it is used only during the terraform provisioning and it is recommended to be changed after the SAP deployment.
# It must contain the relative or absoute path from your Bastion.
# Examples: "ansible/id_rsa_s4hana" , "~/.ssh/id_rsa_s4hana" , "/root/.ssh/id_rsa".

##########################################################
# VPC variables for DR Site
##########################################################

REGION_DR = ""
# The cloud region where to deploy the SAP HANA Secondary System. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc. Supported locations for IBM Cloud Schematics here: https://cloud.ibm.com/docs/schematics?topic=schematics-locations.
# Example: REGION = "eu-gb"

ZONE_DR = ""
# The cloud zone where to deploy the SAP HANA Secondary System. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc.
# Example: ZONE = "eu-gb-1"

VPC_DR = ""
# The name of a NEW or EXISTING VPC for the SAP HANA Secondary System, in the same region as the SAP HANA Secondary System. The list of available VPCs: https://cloud.ibm.com/vpc-ext/network/vpcs
# Example: VPC = "ic4sap-dr"

VPC_DR_EXISTS = ""
# Specifies if the VPC for DR purpose, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_DR_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS.

SUBNET_DR = ""
# The name of a NEW or EXISTING Subnet in the same VPC and same zone as SAP HANA Secondary System. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets.
# Example: SUBNET = "ic4sap-subnet"

SSH_KEYS_DR = [""]
# List of IBM Cloud SSH Keys UUIDs from VPC DR Region, that are allowed to connect via SSH, as root, to the SAP HANA Secondary System. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys.
# Example: SSH_KEYS = ["r010-5ddd21872-c98f-4945-9f69-71c637b1da50", "r010-6dlgg1976-c97f-7935-8dd9-72c637g1ja31"]

##########################################################
# IBM TRANSIT GATEWAY variables
##########################################################

TRANSIT_GATEWAY = ""
# The name of a NEW or an EXISTING IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed. The list of TRANSIT GATEWAYS is available here: https://cloud.ibm.com/interconnectivity/transit.

TRANSIT_GATEWAY_EXISTS = ""
# Specifies if the IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new IBM TRANSIT GATEWAY will be created along with all needed connections. If the IBM TRANSIT GATEWAY_EXISTS is set to yes, only the connections will be created in the existing TRANSIT GATEWAY.
# OBS. Each Subnet can be connected to only one IBM TRANSIT GATEWAY.

SUBNETS_ALREADY_ADDED_ON_TG = ""
# Specifies if the SUBNETS from the PRIMARY VPC and from DR VPC are already added to the TRANSIT GATEWAY as CONNECTONS. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, the SUBNETS will be added to the IBM TRANSIT GATEWAY as new CONNECTONS.

##########################################################
# SAP HANA Servers variables
##########################################################

HANA_SERVER_TYPE = "virtual"
# The type of SAP HANA Server. Supported vales: "virtual".

DB_HOSTNAME_PRIMARY = ""
# The Hostname of SAP HANA Primary System. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: Hostnames of SAP ABAP Platform servers.
# Example: DB_HOSTNAME_PRIMARY = "hanadb-vsi1"

DB_HOSTNAME_DR = ""
# The Hostname for SAP HANA Secondary System that will be deployed in the VPC_DR. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers.
# Example: DB_HOSTNAME_DR = "hanadb-vsi2"

DB_PROFILE = ""
# The instance profile of SAP HANA Primary Server. 
# The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc
# Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles.
# Example of Virtual Server Instance profile for SAP HANA: DB_PROFILE ="mx2-16x128". 
# For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: "SAP Applications on IBM Virtual Private Cloud".

DB_IMAGE = ""
# The OS image of SAP HANA Primary Server. Validated OS images for SAP HANA Server: ibm-redhat-8-6-amd64-sap-hana-6, ibm-redhat-8-4-amd64-sap-hana-10, ibm-sles-15-4-amd64-sap-hana-8, ibm-sles-15-3-amd64-sap-hana-11.
# The list of available VPC Operating Systems supported by SAP: SAP note '2927211 - SAP Applications on IBM Virtual Private Cloud (VPC) Infrastructure environment' https://launchpad.support.sap.com/#/notes/2927211; The list of all available OS images: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images
# Example: DB_IMAGE = "ibm-sles-15-4-amd64-sap-hana-6"

##########################################################
# SAP HANA configuration
##########################################################

KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
# SAP HANA Installation kit path
# Example for Red Hat 8 or Suse 15: KIT_SAPHANA_FILE = "/storage/HANADB/SP07/Rev73/51057281.ZIP"
