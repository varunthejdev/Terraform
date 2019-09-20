data "azurerm_client_config" "current" {}

locals {
    subscription_abbr = "${substr(data.azurerm_client_config.current.subscription_id,-4,-1)}"
}

data "azurerm_resource_group" "storage" {
    name = "${format("%s_%s_RG_STORAGE_%s", local.subscription_abbr, var.resource_group_map[local.subscription_abbr], upper(var.availability_zone))}" # <last4digitsSN>_<LOGICALNAME>_RG_STORAGE_<AZ>
}

data "azurerm_resource_group" "security" {
    name = "${format("%s_%s_RG_SECURITY", local.subscription_abbr, var.resource_group_map[local.subscription_abbr])}" # <last4digitsSN>_<LOGICALNAME>_RG_SECURITY
}

data "azurerm_key_vault" "kv" {
    name = "${format("AKV-%s-UKS", local.subscription_abbr)}"
    resource_group_name = "${data.azurerm_resource_group.security.name}"
}

resource "azurerm_storage_account" "storage_account" {
    count = "${var.number[lower(var.availability_zone)]}"

    name = "${format("%sxxsaxx%sxx%d", local.subscription_abbr, lower(var.availability_zone), count.index + 1 + var.sequence_start)}"
    resource_group_name = "${data.azurerm_resource_group.storage.name}"
    location = "${data.azurerm_resource_group.storage.location}"
    account_kind = "StorageV2"
    account_tier = "Standard"
    account_replication_type = "LRS"
    # account_encryption_source = "Microsoft.Keyvault"

    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_storage_container" "system" {
    count = "${var.number[lower(var.availability_zone)]}"
    name                  = "system"
    resource_group_name   = "${data.azurerm_resource_group.storage.name}"
    storage_account_name  = "${azurerm_storage_account.storage_account.*.name[count.index]}"
    container_access_type = "private"
}

resource "azurerm_key_vault_access_policy" "storage-policy" {
    count = "${var.number[lower(var.availability_zone)]}"

    key_vault_id = "${data.azurerm_key_vault.kv.id}"
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${azurerm_storage_account.storage_account.*.identity.0.principal_id[count.index]}"
  
    key_permissions = [
        "get",
        "wrapKey",
        "unwrapKey"
    ]
}
