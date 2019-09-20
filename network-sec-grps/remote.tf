provider "azurerm" {
  version = "=1.22.0"
  tenant_id = "vb34353463636234313." # Static
  skip_provider_registration = "true"

}

terraform {
  backend "azurerm" {
    storage_account_name = "6463455367dgdh"
    container_name = "tfstate"
    key = "preprod/network-security-groups/tfstate"

    access_key = "ddbcbfg ryhrdv rgtryrdhykju12534543-=-jgfhds5475"
  }
}
