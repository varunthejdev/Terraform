# Configure the Microsoft Azure Provider
#Elavarasan_LLmzeyMXu
provider "azurerm" {
        subscription_id = "7824d53a-63c4-42fd-a57a-30a574015b43"
        client_id       = "087fb653-c307-4ce2-8ed3-fa2d11fe4390"
        client_secret   = "cTwVV.AypS*4J2.LmAzA6Eaiw/zko8BF"
        tenant_id       = "b1a7c303-0faf-4874-a764-0eb184efd96e"
}

locals {
  security_group_rules = csvdecode(file("${path.module}/var.csv"))
}

resource "azurerm_network_security_rule" "elansg" {
  count = length(local.security_group_rules)

  
  name                        = local.security_group_rules[count.index].name
  priority                    = local.security_group_rules[count.index].priority
  direction                   = local.security_group_rules[count.index].direction
  access                      = local.security_group_rules[count.index].access
  protocol                    = local.security_group_rules[count.index].protocol
  source_port_range           = local.security_group_rules[count.index].source_port_range
  destination_port_range      = local.security_group_rules[count.index].destination_port_range
  source_address_prefix       = local.security_group_rules[count.index].source_address_prefix
  destination_address_prefix  = local.security_group_rules[count.index].destination_address_prefix
  resource_group_name         = local.security_group_rules[count.index].resource_group_name
  network_security_group_name = local.security_group_rules[count.index].network_security_group_name
}
