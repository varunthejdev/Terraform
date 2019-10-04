Param(
    [string]$nsgName,
    [string]$resourceGroup,
    [string]$location,
    [string]$tagName,
    [string]$tagValue,
    [string]$defaultCsv,
    [string]$customCsv
) 

#rules array

$rulesArray = @()

#add default rules
Write-Verbose 'Importing Default CSV'
$defaultRules = Import-Csv $defaultCsv

foreach ($defaultRule in $defaultRules) {
    $defaultNsgRule = New-AzureRmNetworkSecurityRuleConfig `
        -Name $defaultRule.ruleName `
        -Description $defaultRule.description `
        -Protocol $defaultRule.protocol `
        -SourcePortRange $defaultRule.sourcePort `
        -DestinationPortRange $defaultRule.destinationPort `
        -SourceAddressPrefix $defaultRule.sourcePrefix `
        -DestinationAddressPrefix $defaultRule.destinationPrefix `
        -Access $defaultRule.access `
        -Priority $defaultRule.priority `
        -Direction $defaultRule.direction

    $rulesArray += $defaultNsgRule
}

#add custom rules
Write-Verbose 'Importing custom CSV'
$customRules = Import-Csv $customCsv

foreach ($customRule in $customRules) {
    $customNsgRule = New-AzureRmNetworkSecurityRuleConfig `
        -Name $customRule.ruleName `
        -Description $customRule.description `
        -Protocol $customRule.protocol `
        -SourcePortRange $customRule.sourcePort `
        -DestinationPortRange $customRule.destinationPort `
        -SourceAddressPrefix $customRule.sourcePrefix `
        -DestinationAddressPrefix $customRule.destinationPrefix `
        -Access $customRule.access `
        -Priority $customRule.priority `
        -Direction $customRule.direction

    $rulesArray += $customNsgRule
}

#creat resource group if necessary
Write-Verbose 'checking resource group'
Try {
    Get-AzureRmResourceGroup -Name $resourceGroup
}
Catch {
    New-AzureRmResourceGroup -Name $resourceGroup -Location $location
}

#create nsg
Write-Verbose 'creating nsg'
New-AzureRmNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroup `
    -Location $location `
    -Tag @{Name=$tagName;Value=$tagValue} `
    -SecurityRules $rulesArray