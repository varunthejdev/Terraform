# Configure the Microsoft Azure Provider
#Gowri_LLmzeyMXu
provider "azurerm" {
        subscription_id = "7824d53a-63c4-42fd-a57a-30a574015b43"
        client_id       = "087fb653-c307-4ce2-8ed3-fa2d11fe4390"
        client_secret   = "cTwVV.AypS*4J2.LmAzA6Eaiw/zko8BF"
        tenant_id       = "b1a7c303-0faf-4874-a764-0eb184efd96e"
}
resource "azurerm_network_security_rule" "gsp" {
  name                        = "test123"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "portalapiazure"
  network_security_group_name = "gsp"
}
