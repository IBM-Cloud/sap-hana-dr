data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

# Create a Transit Gateway with global routing enabled
resource "ibm_tg_gateway" "transit_gateway" {
  name           = "${var.TRANSIT_GATEWAY}"
  global         = true
  location       = var.REGION_PRIMARY
  resource_group = data.ibm_resource_group.group.id
}

/*
# Attach the first VPC to the Transit Gateway
resource "ibm_tg_connection" "connection1" {
  name         = "${var.VPC_PRIMARY_NAME}"
  network_type = "vpc"
  network_id   = var.VPC_PRIMARY
  gateway      = ibm_tg_gateway.transit_gateway.id
}

# Attach the second VPC to the Transit Gateway
resource "ibm_tg_connection" "connection2" {
  name         = "${var.VPC_DR_NAME}"
  network_type = "vpc"
  network_id   = var.VPC_DR
  gateway      = ibm_tg_gateway.transit_gateway.id
}
*/