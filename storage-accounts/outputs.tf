output "storage_accounts" {
  value = "${azurerm_storage_account.storage_account.*.id}"
}
