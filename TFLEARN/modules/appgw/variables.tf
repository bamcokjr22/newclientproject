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

variable "resource_group_name" {
    type = string
}

variable "allocation_method" {
    type = string
}

variable "location" {
    type = string
}

variable "gateway_ip_configuration_name" {
    type = string
}

variable "appgw_subnet_id" {
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

variable "bend_ip_address" {
    type = list(string)
}

variable "bend_fqdns" {
    type = list(string)
}