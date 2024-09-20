variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}


variable "VPC_PRIMARY" {
  type        = string
  description = "VPC name"
}

variable "SUBNET_PRIMARY" {
  type        = string
  description = "SUBNET"
}

variable "VPC_DR" {
  type        = string
  description = "VPC name"
}

variable "SUBNET_DR" {
  type        = string
  description = "SUBNET"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}


