variable "appsvcplan_name" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "location" {
    type = string
}

variable "appsvc_os_type" {
    type = string
}

variable "appsvc_sku_name" {
    type = string
}

variable "lnxappsvc_name" {
    type = string
}

variable "lnxappsvcpe_name" {
    type = string
}

variable "pe_subnet_id" {
    type = string
}

variable "lnxappsvc_con_name" {
    type = string
}

variable "is_manual_connection" {
    type = bool
}

variable "lnxappsvc_pe_dns_zone_grp" {
     type = string
}

variable "lnxappsvc_pe_dns_zone_vlink_name" {
    type = string
}

variable "virtual_network_id" {
    type = string
}

variable "web_subnet_id" {
  type = string
}