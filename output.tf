output "DB_HOSTNAME_DR" {
  value		= var.DB_HOSTNAME_DR
}

output "DB_HOSTNAME_PRIMARY" {
  value		= var.DB_HOSTNAME_PRIMARY 
}

output "DB_PRIVATE_IP_DR" {
  value		= local.ip_dr 
}

output "DB_PRIVATE_IP_PRIMARY" {
  value		= local.ip_primary  
}

output "VPC_DR" {
  value		= var.VPC_DR
}

output "VPC_PRIMARY" {
  value		= var.VPC 
}

output "STORAGE_LAYOUT" {
  value = lower(trimspace(var.HANA_SERVER_TYPE)) == "virtual" ? module.db-vsi[0].STORAGE-LAYOUT : module.db-bms[0].STORAGE-LAYOUT
}

output "TRANSIT_GATEWAY" {
  value		= var.TRANSIT_GATEWAY
}


