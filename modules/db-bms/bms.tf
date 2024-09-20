data "ibm_is_vpc" "vpc" {
  name		= var.VPC
}

data "ibm_is_subnet" "subnet" {
  name		= var.SUBNET
}

data "ibm_is_image" "image" {
  name		= var.IMAGE
}

data "ibm_resource_group" "group" {
  name		= var.RESOURCE_GROUP
}

resource "ibm_is_bare_metal_server" "bms" {
  tags = [ "wes-sap-automation" ]
  vpc            = data.ibm_is_vpc.vpc.id
  zone           = var.ZONE
  resource_group = data.ibm_resource_group.group.id
  keys           = var.SSH_KEYS
  name           = var.HOSTNAME
  profile        = var.PROFILE
  image          = data.ibm_is_image.image.id
  timeouts {
    create = "50m"
    update = "50m"
    delete = "50m"
  }
  primary_network_interface {
    subnet          = data.ibm_is_subnet.subnet.id
    security_groups = flatten([var.SG_DR_1, var.SG_DR_2])
  }
}