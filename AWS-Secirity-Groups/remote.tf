provider "aws" {
  version = "~> 2.0"
  region = "eu-west-2"
}

terraform {
  backend "azurerm" {
    storage_account_name = "021202020xxx"
    container_name = "tfstate"
    key = "aws/network-security-groups/tfstate"

    access_key = "kkbgkdnbdxkjbnkjdb cbkjdfhgdhdgdhnkdg==gdjgjdnhjdnhh=dkrgjreut47kdrgiejfgnb"
  }
}
