resource "azurerm_resource_group" "vnet_resource_group" {
  Count    = "${length(var.location)}"
  name     = "Virtualnetwork_resource_${element(var.location, Count.index)}"
  location = "${element(var.location,Count.index)}"


}
resource "azurerm_resource_group" "infra_resource_group" {
  Count    = "${length(var.location)}"
  name     = "infrastructure_${element(var.location, Count.index)}"
  location = "${element(var.location,Count.index)}"


}

resource "azurerm_virtual_network" "virtual_network" {
  Count               = "${length(var.location)}"
  name                = "VirtualNetwork_${element(var.location,Count.index)}"
  address_space       = ["${element(var.vnet_cidr_range,Count.index)}"]
  location            = "${element(var.location,Count.index)}"
  resource_group_name = "${element(azurerm_resource_group.vnet_resource_group.*.name,Count.index)}"
  dns_servers         = ["${element(var.vnet_dns_server,Count.index)}"]

}
resource "azurerm_route_table" "route_tables" {
  count                         = "${length(var.location)}"
  name                          = "RouteTable_${element(var.location,Count.index)}"
  location                      = "${element(var.location,Count.index)}"
  resource_group_name           = "${element(azurerm_resource_group.vnet_resource_group.*.name,Count.index)}"


}
resource "azurerm_route" "subnet_routes_east" {
  count               = "${length(var.subnet_name_east_values)}"
  name                = "To_${element(var.subnet_name_east_values,count.index)}_Subnet"
  resource_group_name = "${element(azurerm_resource_group.vnet_resource_group.*.name,0)}"
  route_table_name    = "${element(azurerm_route_table.route_tables.*.name,0)}"
  address_prefix      = "${element(var.subnet_east_cidr_range_values,count.index)}"
  next_hop_type       = "VnetLocal"
}
resource "azurerm_route" "subnet_routes_west" {
  count               = "${length(var.subnet_name_west_values)}"
  name                = "To_${element(var.subnet_name_west_values,count.index)}_Subnet"
  resource_group_name = "${element(azurerm_resource_group.vnet_resource_group.*.name,1)}"
  route_table_name    = "${element(azurerm_route_table.route_tables.*.name,1)}"
  address_prefix      = "${element(var.subnet_west_cidr_range_values,count.index)}"
  next_hop_type       = "VnetLocal"
}

resource "azurerm_network_security_group" "network_security_groups" {
  count                         = "${length(var.location)}"
  name                          = "NSG_${element(var.location,Count.index)}"
  location                      = "${element(var.location,Count.index)}"
  resource_group_name           = "${element(azurerm_resource_group.vnet_resource_group.*.name,Count.index)}"


}

resource "azurerm_network_security_rule" "firewalls_network_security_rules_east" {
  count                       = "${length(var.subnet_name_east_values)}"
  name                        = "Allow_Inbound_from_Firewalls"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.firewall_east_cidrRange}"
  destination_address_prefix  = "*"
  resource_group_name         = "${element(azurerm_resource_group.vnet_resource_group.*.name,0)}"
  network_security_group_name = "${element(azurerm_network_security_group.network_security_groups.*.name, 0)}"
}
resource "azurerm_network_security_rule" "firewalls_network_security_rules_west" {
  count                       = "${length(var.subnet_name_west_values)}"
  name                        = "Allow_Inbound_from_Firewalls"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "${var.firewall_west_cidrRange}"
  destination_address_prefix  = "*"
  resource_group_name         = "${element(azurerm_resource_group.vnet_resource_group.*.name,0)}"
  network_security_group_name = "${element(azurerm_network_security_group.network_security_groups.*.name, 0)}"
}
resource "azurerm_subnet" "subnets_east" {
  count                = "${length(var.subnet_name_east_values)}"
  name                 = "${element(var.subnet_name_east_values, count.index)}"
  resource_group_name  = "${element(azurerm_resource_group.vnet_resource_group.*.name,0)}"
  virtual_network_name = "${element(azurerm_virtual_network.virtual_network.*.name,0)}"
  address_prefix       = "${element(var.subnet_east_cidr_range_values, count.index)}"

  network_security_group_id = "${element(azurerm_network_security_group.network_security_groups.*.id,0)}"
  route_table_id            = "${element(azurerm_route_table.route_tables.*.id,0)}"
}
resource "azurerm_subnet" "subnets_west" {
  count                = "${length(var.subnet_name_west_values)}"
  name                 = "${element(var.subnet_name_west_values, count.index)}"
  resource_group_name  = "${element(azurerm_resource_group.vnet_resource_group.*.name,1)}"
  virtual_network_name = "${element(azurerm_virtual_network.virtual_network.*.name,1)}"
  address_prefix       = "${element(var.subnet_west_cidr_range_values, count.index)}"

  network_security_group_id = "${element(azurerm_network_security_group.network_security_groups.*.id,1)}"
  route_table_id            = "${element(azurerm_route_table.route_tables.*.id,1)}"
}
resource "azurerm_network_interface" "nic_web_east" {
  Count               ="${length(var.vm_names)}"
  name                = "nic_${element(var.vm_names, count.index)}"
  resource_group_name = "${element(azurerm_resource_group.infra_resource_group.*.name,0)}"
  location            = "${element(var.location,0)}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${element(azurerm_resazurerm_subnet.subnets_east.*.name,0)}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "east_vm_web" {
  Count                           ="${length(var.vm_names)}"
  name                            = "${element(var.vm_names, count.index)}"
  resource_group_name             = "${element(azurerm_resource_group.infra_resource_group.*.name,0)}"
  location                        = "${element(var.location,0)}"
  admin_username                  = "adminuser"
  network_interface_ids = [
     "${element(azurerm_network_interface.nic_web_east.*.name,Count.index)}",
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
resource "azurerm_network_interface" "nic_web_west" {
  Count               ="${length(var.vm_web_names)}"
  name                = "nic_${element(var.vm_web_names, count.index)}"
  resource_group_name = "${element(azurerm_resource_group.infra_resource_group.*.name,1)}"
  location            = "${element(var.location,0)}"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "${element(azurerm_resazurerm_subnet.subnets_west.*.name,0)}"
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "west_vm_web" {
  Count                           ="${length(var.vm_web_names)}"
  name                            = "${element(var.vm_web_names, count.index)}"
  resource_group_name             = "${element(azurerm_resource_group.infra_resource_group.*.name,0)}"
  location                        = "${element(var.location,0)}"
  admin_username                  = "adminuser"
  network_interface_ids = [
     "${element(azurerm_network_interface.nic_web_west.*.name,Count.index)}",
  ]

  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}