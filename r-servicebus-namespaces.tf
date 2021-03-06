resource "azurerm_servicebus_namespace" "servicebus_namespace" {
  for_each            = var.servicebus_namespaces_queues
  name                = lookup(each.value, "custom_name", format("%s-%s-bus", local.default_name, each.key))
  location            = var.location
  resource_group_name = var.resource_group_name

  sku      = lookup(each.value, "sku", "Basic")
  capacity = lookup(each.value, "capacity", lookup(each.value, "sku", "Basic") == "Premium" ? 1 : 0)

  tags = merge(
    var.extra_tags,
    local.default_tags
  )
}
