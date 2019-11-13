Connect-AzureRmAccount
$subscriptions=Get-AzureRMSubscription

ForEach ($vsub in $subscriptions){
Select-AzureRmSubscription $vsub.SubscriptionID

Write-Host

Write-Host “Working on “ $vsub

Write-Host

Get-AzureRmApplicationSecurityGroup | Format-Table Name,ResourceGroupName,Location | ConvertTo-Csv


}

