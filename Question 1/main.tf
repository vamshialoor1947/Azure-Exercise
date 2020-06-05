resource "azurerm_resource_group" "rg" {
  count                   = "${length(var.location)}"
  name                   = "my-test-candidate-${var.location[count.index]}"
  location               = "${element(var.location,count.index)}"
}

