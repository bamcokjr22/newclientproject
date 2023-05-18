variable "vnet_name" {
    type = string  
}

variable "address_space" {
    type = list(string)
}

variable "location" {
    type = string
}

variable "resource_group_name" {
    type = string
}

variable "subnets" {
    # type = map(any) 
}

variable "appsvcplan_name" {
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

variable "containergrp_name" {
    type = string
}

variable "ip_address_type" {
    type = string
}
    
variable "dns_name_label" {
    type = string
}

variable "os_type" {
    type = string
}

variable "appgwpip" {
    type = string
}

variable "appgw" {
    type = string
}

variable "appgw_sku" {
    type = string
}

variable "appgw_sku_tier" {
    type = string
}

variable "appgw_sku_capacity" {
    type = string
}

variable "allocation_method" {
    type = string
}

variable "gateway_ip_configuration_name" {
    type = string
}

variable "frontend_port_name" {
    type = string
}

variable "frontend_ip_configuration_name" {
    type = string
}

variable "backend_address_pool_name" {
    type = string
}

variable "http_setting_name" {
    type = string
}

variable "listener_name" {
    type = string
}

variable "request_routing_rule_name" {
    type = string
}

variable "trafficmgr_profile_name" {
    type = string
}

variable "traffic_routing_method" {
    type = string
}

variable "dns_config_relative_name" {
    type = string
}

variable "dns_config_ttl" {
}

variable "traffic_mgr_endpoint_name" {
    type = string
}