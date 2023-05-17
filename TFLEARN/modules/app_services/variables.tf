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

variable "winappsvc_name" {
    type = string
}

variable "winappsvcpe_name" {
    type = string
}

variable "pe_subnet_id" {
    type = string
}

variable "winappsvc_con_name" {
    type = string
}

variable "is_manual_connection" {
    type = bool
}

variable "winappsvc_pe_dns_zone_grp" {
     type = string
}