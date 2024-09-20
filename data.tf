# primary

data "ibm_is_vpc" "vpc_primary" {
	provider = ibm.primary
	name		= var.VPC
}

data "ibm_is_instance" "db-vsi-primary" {
	provider = ibm.primary
	count             = var.HANA_SERVER_TYPE == "virtual" ? 1 : 0
	name        = var.DB_HOSTNAME_PRIMARY
}

data "ibm_is_bare_metal_server" "db-bms-primary" {
	provider = ibm.primary
	count             = var.HANA_SERVER_TYPE != "virtual" ? 1 : 0
	name        = var.DB_HOSTNAME_PRIMARY
}

data "ibm_is_subnet" "subnet_primary" {
	provider = ibm.primary
	name		= var.BASTION_SUBNET
}

# secondary

data "ibm_is_vpc" "vpc_secondary" {
	depends_on = [ module.sg-dr ]
	name		= var.VPC_DR
}

data "ibm_is_instance" "db-vsi" {
	count             = var.HANA_SERVER_TYPE == "virtual" ? 1 : 0
	depends_on = [module.db-vsi]
	name        = var.DB_HOSTNAME_DR
}

data "ibm_is_bare_metal_server" "db-bms" {
	count             = var.HANA_SERVER_TYPE != "virtual" ? 1 : 0
	depends_on = [module.db-bms]
	name        = var.DB_HOSTNAME_DR
}

data "ibm_is_subnet" "subnet_secondary" {
	depends_on = [ module.vpc-subnet-dr ]
	name		= var.SUBNET_DR
}

data "ibm_is_security_group" sg-dr-1 {
	depends_on = [ module.sg-dr ]
	name = "sg-dr-${var.DB_HOSTNAME_DR}"
}

data "ibm_is_security_group" sg-dr-2 {
	depends_on = [ module.sg-dr ]
	name = "repo-net-sg-dr-${var.DB_HOSTNAME_DR}"
}

######
locals {
  vpc_primary = data.ibm_is_vpc.vpc_primary.resource_crn
  vpc_secondary = data.ibm_is_vpc.vpc_secondary.resource_crn
  subnet_primary   = data.ibm_is_subnet.subnet_primary.ipv4_cidr_block
  subnet_secondary = data.ibm_is_subnet.subnet_secondary.ipv4_cidr_block
  subnet_primary_id   = data.ibm_is_subnet.subnet_primary.id
  subnet_secondary_id = data.ibm_is_subnet.subnet_secondary.id
  sg_dr_1		= data.ibm_is_security_group.sg-dr-1.id
  sg_dr_2		= data.ibm_is_security_group.sg-dr-2.id
  ip_dr = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms[0].primary_network_interface[0].primary_ip[0].address
  ip_primary = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? data.ibm_is_instance.db-vsi-primary[0].primary_network_interface[0].primary_ip[0].address : data.ibm_is_bare_metal_server.db-bms-primary[0].primary_network_interface[0].primary_ip[0].address
}