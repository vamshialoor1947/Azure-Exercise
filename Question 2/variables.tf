variable "location" {
    type        = "list"
    description = "list of locations"
}
variable "vnet_cidr_range" {
    type        = "list"
    description = "list of vnet_cidr_range"
}
variable "vnet_dns_server" {
    type        = "list"
    description = "list of vnet_dns_server"
}
variable "subnet_name_east_values" {
    type        = "list"
    description = "list of subnet_name_east_values"

variable "subnet_east_cidr_range_values" {
    type        = "list"
    description = "list of subnet_east_cidr_range_values"
}
variable "subnet_name_west_values" {
    type        = "list"
    description = "list of subnet_name_west_values"
}
variable "subnet_west_cidr_range_values" {
    type        = "list"
    description = "list of subnet_west_cidr_range_values"
}
variable "firewall_east_cidrRange" {
    type        = "list"
    description = "list of firewall_east_cidrRange"
}
variable "firewall_west_cidrRange" {
    type        = "list"
    description = "list of firewall_west_cidrRange"
}
variable "vm_web_names" {
    type        = "list"
    description = "list of vm web serverss"
}
