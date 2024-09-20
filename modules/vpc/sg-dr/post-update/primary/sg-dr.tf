data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

# This is the custom SG applied to the bastion instance as coustom source ip/cidr
data "ibm_is_security_group" "sg-primary-update" {
  name  = var.SECURITY_GROUP
}

resource "ibm_is_security_group_rule" "interzone_dr_inbound_ssh_access" {
  group     = data.ibm_is_security_group.sg-primary-update.id
  direction = "inbound"
  #remote    = var.SUBNET_DR
  remote    = var.IP_DR
  tcp {
    port_min = 22
    port_max = 22
  }
}

# ICMP rule for type 8 and any code
resource "ibm_is_security_group_rule" "icmp_dr_inbound_hana_access" {
  group     = data.ibm_is_security_group.sg-primary-update.id
  direction = "inbound"
  #remote    = var.SUBNET_DR
  remote    = var.IP_DR
  
  icmp {
    type = 8
  }

}

# TCP rule for port range 40000-40099
resource "ibm_is_security_group_rule" "tcp_inbound_hana_access" {
  group     = data.ibm_is_security_group.sg-primary-update.id
  direction = "inbound"
  remote    = var.IP_DR
  tcp {
    port_min = 40000
    port_max = 40099
  }
}