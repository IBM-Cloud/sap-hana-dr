variable "RESOURCE_GROUP" {
  type        = string
  description = "Resource Group"
}

variable "IP_DR" {
  type        = string
  description = "IP"
}

variable "IP_PRIMARY" {
  type        = string
  description = "IP"
}

variable "HOSTNAME" {
  type        = string
  description = "VSI Hostname"
}

variable "SECURITY_GROUP" {
    type = string
    description = "Security group name"
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