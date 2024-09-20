data "ibm_resource_group" "group" {
  name = var.RESOURCE_GROUP
}

# This is the custom SG applied to the bastion instance as coustom source ip/cidr
data "ibm_is_security_group" "sg-dr-update" {
  name  = "sg-dr-${var.HOSTNAME}"
}

# TCP rule for port range 40000-40099
resource "ibm_is_security_group_rule" "tcp_inbound_hana_access" {
  group     = data.ibm_is_security_group.sg-dr-update.id
  direction = "inbound"
  remote    = var.IP_PRIMARY
  tcp {
    port_min = 40000
    port_max = 40099
  }
}