output "vnet_name" {
  description = "Name of the Virtual network"
  value       = "${azurerm_virtual_network.virtual_network.*.name}"
}

output "vnet_cidr_range" {
  description = "CIDR Range for the Virtual Network"
  value       = "${azurerm_virtual_network.virtual_network.*.address_space}"
}

output "subent_east_cidr" {
  description = "Resource ID for the Backend Subnet"
   value       = "${azurerm_subnet.subnets_east.*.id}"
}

output "subent_west_cidr" {
  description = "Resource ID for the Backend Subnet"
   value       = "${azurerm_subnet.subnets_west.*.id}"
}
output "east_vms_web" {
  description = "Resource ID for the Backend Subnet"
   value       = "${azurerm_linux_virtual_machine.east_vm_web.*.name}"
}
