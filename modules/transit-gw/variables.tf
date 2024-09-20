variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "VPC_PRIMARY" {
  type        = string
  description = "VPC ID"
}

variable "VPC_PRIMARY_NAME" {
  type        = string
  description = "VPC NAME"
}

variable "SUBNET_PRIMARY" {
  type        = string
  description = "SUBNET"
}

variable "VPC_DR" {
  type        = string
  description = "VPC ID"
}


variable "VPC_DR_NAME" {
  type        = string
  description = "VPC NAME"
}

variable "SUBNET_DR" {
  type        = string
  description = "SUBNET"
}


variable "REGION_DR" {
  type        = string
  description = "REGION_DR"
}

variable "ZONE_DR" {
  type        = string
  description = "ZONE_DR"
}


variable "REGION_PRIMARY" {
  type        = string
  description = "REGION_PRIMARY"
}

variable "TRANSIT_GATEWAY" {
  type        = string
  description = "TRANSIT_GATEWAY"
}