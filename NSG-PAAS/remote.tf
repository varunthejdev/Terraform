provider "azurerm" {
  version = "=1.22.0"
  tenant_id = "5435165468465465465451654" # Static

}

terraform {
  backend "azurerm" {
    storage_account_name = "69d3xxsaxxaz1xx01"
    container_name = "tfstate"
    key = "preprod/network-security-groups/tfstate"

    access_key = "xvxvxvdbbdbdfbdbfjy78980-0-=jgyhdhdgdbdnsgm/l;;#"
  }
}
