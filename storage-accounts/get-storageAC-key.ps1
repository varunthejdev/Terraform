#!/usr/bin/pwsh -Command

Param(
    [Parameter(Mandatory=$true)]
    [string[]] $accountName
)

$storageAccount = Get-AzStorageAccount | Where-Object {$_.StorageAccountName -eq $accountName}
$accountKey = Get-AzStorageAccountKey -Name $storageAccount.StorageAccountName -ResourceGroupName $storageAccount.ResourceGroupName | Select-Object -First 1

Write-Host $accountKey.Value
