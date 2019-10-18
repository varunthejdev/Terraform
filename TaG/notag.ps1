Write-Host "List all resource where Tag value is not Set"
Write-Host "********************************************"
#Fetch all resource details
$resources=get-AzureRmResource
foreach ($resource in $resources) {
    $tagcount=(get-AzureRmResource | where-object {$_.Name -match $resource.Name}).Tags.count
    Write-Host "(get-AzureRmResource | where-object {$_.Name -match $resource.Name}).Tags.count"
    Write-Host $tagcount
    if($tagcount -eq 0) {
        Write-Host "Resource Name - "$resource.Name
        Write-Host "Resource Type and RG Name : " $resource.resourcetype " & " $resource.resourcegroupname "`n"
    }
 }