data "azurerm_client_config" "current" {}

locals {
  subscription_abbr = "${substr(data.azurerm_client_config.current.subscription_id,-4,-1)}"
}

data "azurerm_resource_group" "security" {
  name = "${format("%s_%s_RG_SECURITY", local.subscription_abbr, var.resource_group_map[local.subscription_abbr])}" # <last4digitsSN>_<LOGICALNAME>_RG_SECURITY
}
locals {
  security_group_rules = csvdecode(file("${path.module}/var.csv"))
}

resource "azurerm_network_security_group" "nsg" {
  #count = "${length(var.nsgs)}"
count = length(local.security_group_rules)
  name = "${var.nsgs[count.index]}"
  location = "${data.azurerm_resource_group.security.location}"
  resource_group_name = "${data.azurerm_resource_group.security.name}"

  # This is going to change later
  security_rule {
    name = local.security_group_rules[count.index].name
    priority = local.security_group_rules[count.index].priority
    direction = local.security_group_rules[count.index].direction
    access = local.security_group_rules[count.index].access
    protocol = local.security_group_rules[count.index].protocol
    source_port_range = local.security_group_rules[count.index].source_port_range
    destination_port_range = local.security_group_rules[count.index].destination_port_range
    source_address_prefix = local.security_group_rules[count.index].source_address_prefix
    destination_address_prefix = local.security_group_rules[count.index].destination_address_prefix
  }

  }

resource "azurerm_application_security_group" "asg" {
  count = "${length(var.nsgs)}"

  name = "${replace(var.nsgs[count.index], "NSG", "ASG")}"
  location = "${data.azurerm_resource_group.security.location}"
  resource_group_name = "${data.azurerm_resource_group.security.name}"
}
