module "pre-init-schematics" {
  source = "./modules/pre-init"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "pre-init-cli" {
  source = "./modules/pre-init/cli"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  KIT_SAPHANA_FILE = var.KIT_SAPHANA_FILE
  IP_PRIMARY      = local.ip_primary 
}

module "precheck-ssh-exec" {
  source = "./modules/precheck-ssh-exec"
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  depends_on = [ module.pre-init-schematics ]
    providers       = {
    ibm = ibm.primary
  }
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME = var.DB_HOSTNAME_PRIMARY
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source = "./modules/vpc/subnet"
  depends_on = [ module.precheck-ssh-exec ]
  providers       = {
    ibm = ibm.primary
  }
  VPC = var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  REGION = var.REGION
  SUBNET = var.BASTION_SUBNET
}

module "vpc-dr" {
  source         = "./modules/vpc"
  RESOURCE_GROUP = var.RESOURCE_GROUP 
  VPC        = var.VPC_DR 
  count          = var.VPC_DR_EXISTS == "no" ? 1 : 0
  REGION = var.REGION_DR 
}

module "vpc-subnet-dr" {
  source         = "./modules/vpc/subnet-dr"
  depends_on = [ module.vpc-dr ]
  count          = var.VPC_DR_EXISTS == "no" ? 1 : 0
  RESOURCE_GROUP = var.RESOURCE_GROUP
  VPC            = var.VPC_DR
  ZONE = var.ZONE_DR
  SUBNET = var.SUBNET_DR
  HOSTNAME		= var.DB_HOSTNAME_DR

}

module "sg-dr" {
  depends_on = [module.vpc-subnet-dr, module.vpc-subnet]
  source          = "./modules/vpc/sg-dr"
  RESOURCE_GROUP  = var.RESOURCE_GROUP
  HOSTNAME        = var.DB_HOSTNAME_DR
  VPC_DR          = var.VPC_DR
  SUBNET_DR       = local.subnet_secondary
  VPC_PRIMARY     = var.VPC
  SUBNET_PRIMARY  = local.subnet_primary 
}

module "transit-gw" {
  depends_on = [module.vpc-subnet-dr, module.vpc-subnet]
  source          = "./modules/transit-gw"
  count          = var.TRANSIT_GATEWAY_EXISTS == "no" ? 1 : 0
  RESOURCE_GROUP  = var.RESOURCE_GROUP 
  HOSTNAME        = var.DB_HOSTNAME_DR
  VPC_DR          = local.vpc_secondary
  VPC_DR_NAME     = var.VPC_DR
  SUBNET_DR       = local.subnet_secondary_id
  REGION_DR       = var.REGION_DR
  ZONE_DR         = var.ZONE_DR
  VPC_PRIMARY     = local.vpc_primary
  VPC_PRIMARY_NAME = var.VPC 
  SUBNET_PRIMARY  = local.subnet_primary_id
  REGION_PRIMARY  = var.REGION 
  #ZONE_PRIMARY    = var.ZONE 
  TRANSIT_GATEWAY = var.TRANSIT_GATEWAY
}

module "transit-gw-connections" {
  depends_on = [module.vpc-subnet-dr, module.vpc-subnet, module.transit-gw]
  source          = "./modules/transit-gw/connections"
  count          = var.SUBNETS_ALREADY_ADDED_ON_TG == "no" ? 1 : 0
  RESOURCE_GROUP  = var.RESOURCE_GROUP 
  HOSTNAME        = var.DB_HOSTNAME_DR
  VPC_DR          = local.vpc_secondary
  VPC_DR_NAME     = var.VPC_DR
  SUBNET_DR       = local.subnet_secondary_id
  SUBNET_DR_NAME  = var.SUBNET_DR
  REGION_DR       = var.REGION_DR
  ZONE_DR         = var.ZONE_DR
  VPC_PRIMARY     = local.vpc_primary
  VPC_PRIMARY_NAME = var.VPC 
  SUBNET_PRIMARY  = local.subnet_primary_id
  SUBNET_PRIMARY_NAME       = var.BASTION_SUBNET
  REGION_PRIMARY  = var.REGION 
  # ZONE_PRIMARY    = var.ZONE
  TRANSIT_GATEWAY = var.TRANSIT_GATEWAY 
}

module "db-vsi" {
  source		= "./modules/db-vsi"
  depends_on	= [ module.precheck-ssh-exec , module.vpc-subnet-dr, module.sg-dr, module.transit-gw-connections]
  count = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? 1 : 0
  ZONE			= var.ZONE_DR
  VPC			= var.VPC_DR 
  SG_DR_1 = [local.sg_dr_1] 
  SG_DR_2 = [local.sg_dr_2]
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SUBNET		= var.SUBNET_DR
  HOSTNAME		= var.DB_HOSTNAME_DR
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  SSH_KEYS		= var.SSH_KEYS_DR
}

module "db-bms" {
  source		= "./modules/db-bms"
  depends_on	= [ module.precheck-ssh-exec , module.vpc-subnet-dr, module.sg-dr, module.transit-gw-connections]
  count = lower(trimspace(var.HANA_SERVER_TYPE)) != "virtual" ? 1 : 0
  ZONE			= var.ZONE_DR
  VPC			= var.VPC_DR
  SG_DR_1 = [local.sg_dr_1]  
  SG_DR_2 = [local.sg_dr_2] 
  SUBNET		= var.SUBNET_DR
  HOSTNAME		= var.DB_HOSTNAME_DR
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SSH_KEYS		= var.SSH_KEYS_DR
}

module "sg-dr-post-update" {
  depends_on = [module.db-vsi, module.db-bms]
  source     = "./modules/vpc/sg-dr/post-update" 
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME       = var.DB_HOSTNAME_DR
  IP_DR    = local.ip_dr 
  IP_PRIMARY      = local.ip_primary  
}

module "sg-dr-post-update-primary" {
  depends_on = [module.db-vsi, module.db-bms]
  source     = "./modules/vpc/sg-dr/post-update/primary" 
   providers       = {
    ibm = ibm.primary
  }
  RESOURCE_GROUP  = var.RESOURCE_GROUP
  SECURITY_GROUP = var.SECURITY_GROUP 
  HOSTNAME        = var.DB_HOSTNAME_PRIMARY
  VPC_DR          = var.VPC_DR
  SUBNET_DR       = local.subnet_secondary
  VPC_PRIMARY     = var.VPC 
  SUBNET_PRIMARY  = local.subnet_primary  
  IP_PRIMARY      = local.ip_primary 
  IP_DR    = local.ip_dr 
}

module "ansible-exec-schematics" {
  source  = "./modules/ansible-exec"
  depends_on = [ local_file.ansible_inventory, local_file.ansible_saphana-vars, module.transit-gw-connections, module.sg-dr-post-update-primary, module.sg-dr-post-update ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 0 : 1)
  IP = local.ip_dr
  PLAYBOOK = "saphana_dr.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "ansible-exec-cli" {
  source  = "./modules/ansible-exec/cli"
  depends_on = [ local_file.ansible_inventory, local_file.ansible_saphana-vars, module.transit-gw-connections, module.sg-dr-post-update-primary, module.sg-dr-post-update ]
  count = (var.PRIVATE_SSH_KEY == "n.a" && var.BASTION_FLOATING_IP == "localhost" ? 1 : 0)
  ID_RSA_FILE_PATH = var.ID_RSA_FILE_PATH
  HANA_MAIN_PASSWORD = var.HANA_MAIN_PASSWORD
  IP = local.ip_dr
  PLAYBOOK = "saphana_dr.yml"
}