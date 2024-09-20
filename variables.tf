##########################################################
# General & Default VPC variables for CLI deployment
##########################################################

variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "id_rsa private key content in OpenSSH format (Sensitive* value). This private key should be used only during the terraform provisioning and it is recommended to be changed after the SAP deployment."
        nullable = false
        validation {
        condition = length(var.PRIVATE_SSH_KEY) >= 64 && var.PRIVATE_SSH_KEY != null && length(var.PRIVATE_SSH_KEY) != 0 || contains(["n.a"], var.PRIVATE_SSH_KEY )
        error_message = "The content for private_ssh_key variable must be completed in OpenSSH format."
     }
}

variable "ID_RSA_FILE_PATH" {
    default = "ansible/id_rsa"
    nullable = false
    description = "The file path for PRIVATE_SSH_KEY. It will be automatically generated. If it is changed, it must contain the relative path from git repo folders. Example: ansible/id_rsa_ase_hana"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "List of IBM Cloud SSH Keys UUIDs from Primary Hana Region, that are allowed to connect via SSH, as root, to the Primary SAP HANA server. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the SAP HANA Server."
	}
}

variable "BASTION_FLOATING_IP" {
        type            = string
        description = "The FLOATING IP of the Bastion Server in the same VPC where the SAP HANA Primary System is deployed. It can be copied from the Bastion Server Deployment \"OUTPUTS\" at the end of \"Apply plan successful\" message."
        nullable = false
        validation {
        condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.BASTION_FLOATING_IP)) || contains(["localhost"], var.BASTION_FLOATING_IP ) && var.BASTION_FLOATING_IP!= null
        error_message = "Incorrect format for variable: BASTION_FLOATING_IP."
      }
}

variable "BASTION_SUBNET" {
	type		= string
	description = "The name of an EXISTING Subnet that belongs to the BASTION VSI in the same VPC where the SAP HANA Primary System is deployed. This variable is for deployment and DR purposes throught the private BASTION NETWORK ONLY. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.BASTION_SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "The name of an EXISTING Resource Group for SAP HANA Server and Volumes resources. The list of Resource Groups is available here: https://cloud.ibm.com/account/resource-groups."
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "The cloud region where the SAP HANA Primary System is deployed. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc."
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION )
		error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "VPC" {
	type		= string
	description = "The name of an EXISTING VPC where the SAP HANA Primary System is deployed. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "The name of an EXISTING Security group for the VPC where the SAP HANA Primary System is deployed. It can be copied from the Bastion Server Deployment \"OUTPUTS\" at the end of \"Apply plan successful\" message. The list of Security Groups is available here: https://cloud.ibm.com/vpc-ext/network/securityGroups."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

################################ > DR

variable "REGION_DR" {
	type		= string
	description	= "The cloud region where to deploy the SAP HANA Secondary System. The regions and zones for VPC are listed here:https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc."
	validation {
		condition     = contains(["au-syd", "jp-osa", "jp-tok", "eu-de", "eu-gb", "ca-tor", "us-south", "us-east", "br-sao"], var.REGION_DR )
		error_message = "For CLI deployments, the REGION must be one of: au-syd, jp-osa, jp-tok, eu-de, eu-gb, ca-tor, us-south, us-east, br-sao. \n For Schematics, the REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE_DR" {
	type		= string
	description	= "The cloud zone where to deploy the SAP HANA Secondary System. The available regions and zones for VPC can be found here: https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc"
	validation {
		condition     = length(regexall("^(au-syd|jp-osa|jp-tok|eu-de|eu-gb|ca-tor|us-south|us-east|br-sao)-(1|2|3)$", var.ZONE_DR)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC_DR" {
	type		= string
	description = "The name of a NEW or EXISTING VPC for the SAP HANA Secondary System, in the same region as the SAP HANA Secondary System. The list of VPCs is available here: https://cloud.ibm.com/vpc-ext/network/vpcs."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC_DR)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "VPC_DR_EXISTS" {
  type            = string
  description     = "Specifies if the VPC for DR purpose, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new VPC will be created along with all supplied SUBNETS in the provided ZONES. If the VPC_DR_EXISTS is set to yes, the specified SUBNETS are verified to determine if they exist in the provided VPC; if any of the user-provided SUBNETS do not exist in the existing VPC, those subnets are created using the selected ZONES and SUBNETS."
  validation {
    condition     = var.VPC_DR_EXISTS == "yes" || var.VPC_DR_EXISTS == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "SUBNET_DR" {
	type		= string
	description = "The name of a NEW or EXISTING Subnet in the same VPC and same zone as SAP HANA Secondary System. The list of Subnets is available here: https://cloud.ibm.com/vpc-ext/network/subnets."
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET_DR)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SSH_KEYS_DR" {
	type		= list(string)
	description = "List of IBM Cloud SSH Keys UUIDs from VPC DR Region, that are allowed to connect via SSH, as root, to the SAP HANA Secondary System. The SSH Keys should be created for the same region as the SAP HANA server. Can contain one or more IDs. Example: [\"r010-5db21872-c98f-4945-9f69-71c637b1da50\", \"r010-6dl21976-c97f-7935-8dd9-72c637g1ja31\"]. The list of SSH Keys is available here: https://cloud.ibm.com/vpc-ext/compute/sshKeys."
	validation {
		condition     = var.SSH_KEYS_DR == [] ? false : true && var.SSH_KEYS_DR == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the SAP HANA Server."
	}
}

################################ < DR

################################ > TG

variable "TRANSIT_GATEWAY" {
	type		= string
	description = "The name of a NEW or an EXISTING IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed. The list of TRANSIT GATEWAYS is available here: https://cloud.ibm.com/interconnectivity/transit."
	validation {
		condition     = length(var.TRANSIT_GATEWAY) <= 20 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.TRANSIT_GATEWAY)) > 0
		error_message = "The TRANSIT_GATEWAY name is not valid."
	}
}

variable "TRANSIT_GATEWAY_EXISTS" {
  type            = string
  description     = "Specifies if the IBM TRANSIT GATEWAY for the VPC where the SAP HANA Primary System is deployed, having the provided name, already exists. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, a new IBM TRANSIT GATEWAY will be created along with all needed connections. If the IBM TRANSIT GATEWAY_EXISTS is set to yes, only the connections will be created in the existing TRANSIT GATEWAY."
  validation {
    condition     = var.TRANSIT_GATEWAY_EXISTS == "yes" || var.TRANSIT_GATEWAY_EXISTS == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}

variable "SUBNETS_ALREADY_ADDED_ON_TG" {
  type            = string
  description     = "Specifies if the SUBNETS from the PRIMARY VPC and from DR VPC are already added to the TRANSIT GATEWAY as CONNECTONS. Allowed values: 'yes' and 'no'.\n If the value 'no' is chosen, the SUBNETS will be added to the IBM TRANSIT GATEWAY as new CONNECTONS."
  validation {
    condition     = var.SUBNETS_ALREADY_ADDED_ON_TG == "yes" || var.SUBNETS_ALREADY_ADDED_ON_TG == "no"
    error_message = "The value for this parameter can only be yes or no."
  }
}


################################ < TG

variable "HANA_SERVER_TYPE" {
	type		= string
	description = "The type of SAP HANA Server. Supported values: \"virtual\"."
	default = "virtual"
	validation {
		condition = contains(["virtual"], var.HANA_SERVER_TYPE)
		error_message = "The type of SAP HANA server is not valid. The allowed values should be one of the following: \"virtual\"."
	}
}

variable "DB_HOSTNAME_PRIMARY" {
	type		= string
	description = "The Hostname of SAP HANA Primary System. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME_PRIMARY) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_PRIMARY)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_HOSTNAME_DR" {
	type		= string
	description = "The Hostname for SAP HANA Secondary System that will be deployed in the VPC_DR. The hostname should be up to 13 characters as required by SAP. For more information on rules regarding hostnames for SAP systems, check SAP Note 611361: \"Hostnames of SAP ABAP Platform servers\"."
	validation {
		condition     = length(var.DB_HOSTNAME_DR) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME_DR)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "The instance profile of SAP HANA Primary Server. The list of certified profiles for SAP HANA Virtual Servers is available here: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc. Details about all x86 instance profiles are available here: https://cloud.ibm.com/docs/vpc?topic=vpc-profiles. Example of Virtual Server Instance profile for SAP HANA: \"mx2-16x128\". For more information about supported DB/OS and IBM VPC, check SAP Note 2927211: \"SAP Applications on IBM Virtual Private Cloud\"."
	validation {
		condition     = length(var.DB_PROFILE) > 0
    	error_message = "The profile for SAP HANA Servers cannot be empty. The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 	}
}

variable "DB_IMAGE" {
	type		= string
	description = "The OS image of SAP HANA Primary Server. A list of images is available here: https://cloud.ibm.com/docs/vpc?topic=vpc-about-images."
	validation {
		condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-hana|ibm-sles-15-(3|4)-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
        error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-x\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 	}
}

# HANA SERVER PROFILE
resource "null_resource" "check_profile" {
  count             = var.DB_PROFILE != "" ? 1 : 0
  lifecycle {
    precondition {
      condition     = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? contains(keys(jsondecode(file("${path.root}/modules/db-vsi/files/hana_vm_volume_layout.json")).profiles), "${var.DB_PROFILE}") : contains(keys(jsondecode(file("${path.root}/modules/db-bms/files/hana_bm_volume_layout.json")).profiles), "${var.DB_PROFILE}")
      error_message = "The chosen storage PROFILE for SAP HANA Server \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI form https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc or for HANA BM Server from https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-bm-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
    }
  }
}

##############################################################
# The variables and data sources used in SAP Ansible Modules.
##############################################################

variable "HANA_SID" {
	type		= string
	description = "EXISTING SAP HANA system ID on the primary SAP HANA system. The SAP system ID identifies the SAP HANA system. Should follow the SAP rules for SID naming."
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0  && !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN", "RAW", "REF", "ROW", "SAP", "SET", "SGA", "SHG", "SID", "SQL", "SUM", "SYS", "TMP", "TOP", "UID", "USE", "USR", "VAR"], var.HANA_SID)
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "EXISTING SAP HANA instance number on the primary SAP HANA system. Specifies the instance number of the SAP HANA system. Should follow the SAP rules for instance number naming"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_TENANTS" {
	type        = list(string)
	description = "A list of EXISTING SAP HANA tenant databases on the primary SAP HANA system. Examples: [\"HDB\"] or [\"Ten_HDB1\", \"Ten_HDB2\", ..., \"Ten_HDBn\"]"
	validation {
		condition     = length(var.HANA_TENANTS) > 0
		error_message = "SAP HANA Tenant list can not be empty. Examples: [\"HDB\"] or [\"Ten1\", \"Ten2\"]"
	}
	validation {
		condition     = alltrue([for tenant in var.HANA_TENANTS : !contains(["ADD", "ALL", "AMD", "AND", "ANY", "ARE", "ASC", "AUX", "AVG", "BIT", "CDC", "COM", "CON", "DBA", "END", "EPS", "FOR", "GET", "GID", "IBM", "INT", "KEY", "LOG", "LPT", "MAP", "MAX", "MIN", "MON", "NIX", "NOT", "NUL", "OFF", "OLD", "OMS", "OUT", "PAD", "PRN","RAW","REF","ROW","SAP","SET","SGA","SHG","SID","SQL","SUM","SYS","TMP","TOP","UID","USE","USR","VAR"], upper(tenant))])
		error_message = "${join(", ", var.HANA_TENANTS)} is an invalid hana_tenant value."
	}
	validation {
		condition     = alltrue([for tenant in var.HANA_TENANTS : length(upper(tenant)) <= 253]) && alltrue([for s in var.HANA_TENANTS : can(regex("^\\w+$", s))])
		error_message = "${join(", ", var.HANA_TENANTS)} contains invalid hana_tenant values."
	}

}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "Common password for all users that are created during the installation."
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "EXISTING system usage of the primary SAP HANA system. Valid values: \"production\", \"test\", \"development\", \"custom\"."
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "EXISTING SAP HANA components on the primary SAP HANA system. Valid values: \"all\", \"client\", \"es\", \"ets\", \"lcapps\", \"server\", \"smartda\", \"streaming\", \"rdsync\", \"xs\", \"studio\", \"afl\", \"sca\", \"sop\", \"eml\", \"rme\", \"rtl\", \"trp\"."
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "Path to SAP HANA kit file. As downloaded from SAP Support Portal."
	default		= "/storage/HANADB/SP07/Rev73/51057281.ZIP"
	validation {
		condition     = length(regex("(^|\\/|\\.)[[:digit:]]+\\.ZIP", var.KIT_SAPHANA_FILE)) > 0
		error_message = "The name of the KIT_SAPHANA_FILE is not valid."
	}
}

