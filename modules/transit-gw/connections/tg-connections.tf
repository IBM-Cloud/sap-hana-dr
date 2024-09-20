data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

data "ibm_tg_gateway" "transit_gateway_data" {
  name		= var.TRANSIT_GATEWAY
}

# Attach the first VPC to the Transit Gateway
resource "ibm_tg_connection" "vpc_primary" {
  name         = "${var.VPC_PRIMARY_NAME}-${var.REGION_PRIMARY}"
  network_type = "vpc"
  network_id   = var.VPC_PRIMARY
  gateway      = data.ibm_tg_gateway.transit_gateway_data.id
}

# Attach the second VPC to the Transit Gateway
resource "ibm_tg_connection" "vpc_dr" {
  name         = "${var.VPC_DR_NAME}-${var.REGION_DR}"
  network_type = "vpc"
  network_id   = var.VPC_DR
  gateway      = data.ibm_tg_gateway.transit_gateway_data.id
}