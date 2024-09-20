data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

# Secondary Site

data "ibm_is_vpc" "vpc_dr" {
  name = var.VPC_DR
}

# This is the custom SG applied to the bastion instance as coustom source ip/cidr
resource "ibm_is_security_group" "sg-dr_dr" {
  name           = "sg-dr-${var.HOSTNAME}"
  vpc            = data.ibm_is_vpc.vpc_dr.id
  resource_group = data.ibm_resource_group.group.id
}

resource "ibm_is_security_group_rule" "interzone_dr_inbound_ssh_access_1" {
  group     = ibm_is_security_group.sg-dr_dr.id
  direction = "inbound"
  remote    = var.SUBNET_PRIMARY
  tcp {
    port_min = 22
    port_max = 22
  }
}

# ICMP rule for type 8 and any code
resource "ibm_is_security_group_rule" "icmp_dr_inbound_hana_access_1" {
  group     = ibm_is_security_group.sg-dr_dr.id
  direction = "inbound"
  remote    = var.SUBNET_PRIMARY
  
  icmp {
    type = 8
  }

}