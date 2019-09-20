#!/usr/bin/pwsh -Command

Param(
    [Parameter(Mandatory=$true)]
    [string] $subscriptionId,

    [parameter(Mandatory=$true)]
    [string] $accessId,

    [parameter(Mandatory=$true)]
    [string] $secret,

    [Parameter(Mandatory=$true)]
    [string] $availabilityZone,

    [Parameter(Mandatory=$true)]
    [string[]] $storageAccounts
)

$tenantid = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

try {
    $secureSecret = ConvertTo-SecureString -String $secret -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential ($accessId, $secureSecret)
    Connect-AzAccount -ServicePrincipal -Credential $credential -TenantId $tenantid
} catch {
    Write-Error ($_.InvocationInfo | Format-List -Force | Out-String)
}

Set-AzContext -Subscription $subscriptionId

$storageAccounts = $storageAccounts
$subscriptionLastCharacters = $subscriptionId.Substring($subscriptionId.Length - 4)
$vaultName = "AKV-" + $subscriptionLastCharacters + "-UKS"
$keyNameRegex = "$subscriptionLastCharacters.*-CMK-VM-$availabilityZone"


foreach ($act in $storageAccounts) {
    $storageAccountObject = Get-AzStorageAccount | Where-Object {$_.StorageAccountName -eq $act}
    if ($null -eq $storageAccountObject.Encryption.KeyVaultProperties) {
        $keyVault = Get-AzKeyVault -VaultName $vaultName
        $key = Get-AzKeyVaultKey -VaultName $vaultName | Where-Object {$_.Name -match $keyNameRegex}
        $keyVersion = (Get-AzKeyVaultKey -VaultName $vaultName -KeyName $key.Name).Version
        Set-AzStorageAccount -ResourceGroupName $storageAccountObject.ResourceGroupName -AccountName $act -KeyvaultEncryption -KeyName $key.Name -KeyVersion $keyVersion -KeyVaultUri $keyVault.VaultUri
    }
}
