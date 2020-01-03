# Configure the Microsoft Azure Provider
#Gowri_LLmzeyMXu
#Change the value befores executing the script
provider "azurerm" {
        subscription_id = "XXXX-XXXXX-42fd-a57a-30a574015b43"
        client_id       = "087fb653-XXXX-XXXX-8ed3-fa2d11fe4390"
        client_secret   = "cTwVV.XXX*4J2.XXXXX/zko8BF"
        tenant_id       = "b1a7c303-XXXX-4874-a764-XXXXXefd96e"
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
