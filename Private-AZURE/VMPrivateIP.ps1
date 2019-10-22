
<# Uncomment and execute the command and restart the powershell. If you get following ERROR
    Login-AzureRmAccount : Method 'get_SerializationSettings' in type 'Microsoft.Azure.Management.Internal.Resources.ResourceManagementClient' from assembly 'Microsoft.Azure.Commands.ResourceManager.Common, 
    Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' does not have an implementation.
    At line:1 char:1
#>


#import-module -Name Azurerm  
         
$fileName1 = "VirtualMachinesIPs.csv" 
$fileName2 = "VirtualMachinePrivateIPs.CSV" 
    

if (Test-Path $fileName1)
{
Remove-Item $fileName1
Remove-Item $fileName2

}


$VMstring = ("vm","Pro","ansible")   #Delcaration of the string to be searched on the VM Name



class VMWithPublicIP {
    $TenantName
    $SubscriptionName
    $ResourceGroupName
    $VMName
	$OSType
    $PublicIP
}

class VMWithPrivateIP {
 
    $VMname
    $ResourceGroupName
    $Region
    $VirturalNetwork
    $Subnet
    $PrivateIpAddress
    $OsType
}

Function Write-Logging {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","DEBUG","WARN","ERROR")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile = "$File"
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}


$ConnectionStatus=$false
try {
#    Login-AzureRmAccount -ErrorAction Stop | Out-Null    #### Need to uncomment and Login to Azure account for first time
    Write-Host (Get-Date -UFormat '%d-%m-%y %I:%M:%S') "Connected to Azure."
    $ConnectionStatus=$true
} catch {
    Write-Host (Get-Date -UFormat '%d-%m-%y %I:%M:%S') "ERROR Occured ==> Please login again."
    $ConnectionStatus=$false
}

if($ConnectionStatus) {
    Write-Logging -Message "######################################################################" -logfile ".\log.txt"
    Write-Logging -Message "Script Started at - $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")" -logfile ".\log.txt"
    Write-Host "######################################################################"
    Write-Host "Script Started at - $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")" -ForegroundColor Red -BackgroundColor Green
    Write-Host "######################################################################"
    Write-Logging -Message "$(Get-Date -Format "dd-MMM-yyyy HH:mm:ss"): Listing of available Tenants" -logfile ".\log.txt"
    Write-Host "$(Get-Date -Format "dd-MMM-yyyy HH:mm:ss"): Listing of available Tenants."
    $vmWithPubIPs = New-Object 'System.Collections.Generic.List[VMWithPublicIP]'
    $vmWithPrivateIPs = New-Object 'System.Collections.Generic.List[VMWithPrivateIP]'
    $tenantID = Get-AzureRmTenant
	for($i=0; $i -lt $tenantID.Count; $i++){
        Write-Logging -Message "Selected the TenantID: $($tenantID[$i].Id)" -logfile ".\log.txt"
        Write-Host "Selecting the TenantID: $($tenantID[$i].Id)."
        $subscriptionID = Get-AzureRmSubscription -TenantId $tenantID[$i].Id
        Write-Logging -Message "There are around: $($subscriptionID.Count) Subscription." -logfile ".\log.txt"
        Write-Host "There are around: $($subscriptionID.Count) Subscription."
		for($s=0; $s -lt $subscriptionID.Count; $s++){
            Select-AzureRmSubscription -SubscriptionId $subscriptionID[$s].Id
            Write-Host "Selecting the SubscriptionID: $($subscriptionID[$s].Id)"
            Write-Logging -Message "Selected the Subscription ID: $($subscriptionID[$s].Id) with Name: $($subscriptionID[$s].Name)" -logfile ".\log.txt"
            $vms = Get-AzureRmVM
            Write-Host "Fetching list of Virtual Machines in Subscription. Count: $($vms.Count)"
            Write-Logging -Message "Fetching list of Virtual Machines in Subscription. Count: $($vms.Count)" -logfile ".\log.txt"
            $nics = Get-AzureRmNetworkInterface | ?{ $_.VirtualMachine -ne $null }
            Write-Host "Fetching list of Network Interfaces associated with VM and has a Public IPs. Count: $($nics.Count)"
            Write-Logging -Message "Fetching list of Network Interfaces associated with VM and has a Public IPs. Count: $($nics.Count)" -logfile ".\log.txt"
            
           
            
			#for($n=0; $n -lt $nics.Count; $n++)
          #  {
               
                
				#$listVMs = New-Object VMWithPublicIP
                
                
                #$listVMs.TenantName = $tenantID[$i].Directory
                #$listVMs.SubscriptionName = $subscriptionID[$s].Name
                #$vm = $vms |? -Property Id -eq $nics[$n].VirtualMachine.Id
                #$listVMs.ResourceGroupName = $vm.ResourceGroupName
                #$listVMs.VMName = $vm.Name
                #Write-Host Start + $listVms.VMName
				#$listVMs.OSType = $vm.StorageProfile.OsDisk.OsType
                                    # $listVMs.PublicIP = (Get-AzureRmPublicIpAddress | Where-Object {$_.Id -eq $nics[$n].IpConfigurations.PublicIpAddress.Id}).IpAddress
                

               # $tempvariable = $vm.Name
               
                #foreach($VMstrings in $VMstring)
                #{
                #if($tempvariable.Contains($VMstrings)) #### Matching VM Name strings with all VM from all subscription
                #{

                #$vmWithPubIPs.Add($listVMs)  ###  Adding the values to CSV file
                #Write-Host "Found a VM: $($vm.Name) with Public IP associated in Subscription: $($subscriptionID[$s].Name)"
                #Write-Logging -Message "Found a VM: $($vm.Name) with Public IP associated in Subscription: $($subscriptionID[$s].Name)" -logfile ".\log.txt"
                
                #}
               # }
                #Provide the name of the csv file to be exported
#$reportName = "myReport.csv"

#Select-AzSubscription $subscriptionId
$report = @()
#$vms = Get-AzVM
#$publicIps = Get-AzPublicIpAddress 
#$nics = Get-AzNetworkInterface | ?{ $_.VirtualMachine -NE $null} 
foreach ($nic in $nics) { 
    $info = "" | Select VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress, TenantID ,SubscriptionName
    $vm = $vms | ? -Property Id -eq $nic.VirtualMachine.id 
    #foreach($publicIp in $publicIps) { 
        #if($nic.IpConfigurations.id -eq $publicIp.ipconfiguration.Id) {
            #$info.PublicIPAddress = $publicIp.ipaddress
           # } 
        #} 
        $info.TenantID = $vm.Identity.TenantId
        $info.SubscriptionName = $vm.Id
        $info.OsType = $vm.StorageProfile.OsDisk.OsType 
        $info.VMName = $vm.Name 
        $info.ResourceGroupName = $vm.ResourceGroupName 
        $info.Region = $vm.Location 
        $info.VirturalNetwork = $nic.IpConfigurations.subnet.Id.Split("/")[-3] 
        $info.Subnet = $nic.IpConfigurations.subnet.Id.Split("/")[-1] 
        $info.PrivateIpAddress = $nic.IpConfigurations.PrivateIpAddress 
        $report+= $info
        #$vmWithPrivateIPs.Add($info)
        $output+=$report
    } 
    
              
$report | ft VmName, ResourceGroupName, Region, VirturalNetwork, Subnet, PrivateIpAddress, OsType, PublicIPAddress,TenantID,SubscriptionName  
 #$report | Export-CSV "$home/$reportName"
 

            
            #}
            
        }
        $Result+=$output
    }
  # $report | Export-CSV "$home/$reportName" 
    #$Result | Export-Csv "VirtualMachinesIPs.csv" -NoTypeInformation
    $output | Export-CSV "VirtualMachinePrivateIPs.CSV" -NoTypeInformation
    
    Write-Host ""
    Write-Host "######################################################################"
    Write-Logging -Message "Script Ended at - $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")" -logfile ".\log.txt"
    Write-Logging -Message "######################################################################" -logfile ".\log.txt"
    Write-Host "Script Ended at - $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")" -ForegroundColor Red -BackgroundColor Green
    Write-Host "######################################################################"

} else {
    Write-Logging -Message "Script exited as No Proper Credentials - $(Get-Date -Format "dd-MMM-yyyy HH:mm:ss")" -logfile ".\log.txt"
    Write-Logging -Message "######################################################################" -logfile ".\log.txt"
    Write-Host "######################################################################"
    Write-Host (Get-Date -UFormat '%d-%m-%y %I:%M:%S') "Script exited as No Credentials are passed to run this script."
}