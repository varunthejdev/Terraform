﻿<#
    .SYNOPSIS
      This powershell script will export all the VMs with the Public IPs.

    .DESCRIPTION
      The script will loop through all the Tenants with individual Subscription and filters Virtual Machine with Public IPs associated.  
	  The Output is a csv generated in the same location as the script is executed from powershell which will have these properties: Tenant Name, Subscription Name, Resource Group Name, Virtual Machine Name, OS Type(Windows/Linux), Public IP
	
    .EXAMPLE
      .\azure.vm.publicip.ps1

    .Purpose/Change: This powershell script will export all the VMs with the Public IPs.
#>

#Enter the Strings to matched to the VM name

$VMstring = ("vm","Pro","ansible")



class VMWithPublicIP {
    $TenantName
    $SubscriptionName
    $ResourceGroupName
    $VMName
	$OSType
    $PublicIP
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
            $nics = Get-AzureRmNetworkInterface | ?{ $_.VirtualMachine -ne $null -and $_.IpConfigurations.PublicIpAddress -ne $null}
            Write-Host "Fetching list of Network Interfaces associated with VM and has a Public IPs. Count: $($nics.Count)"
            Write-Logging -Message "Fetching list of Network Interfaces associated with VM and has a Public IPs. Count: $($nics.Count)" -logfile ".\log.txt"
            
           
            
			for($n=0; $n -lt $nics.Count; $n++)
            {
               
                
				$listVMs = New-Object VMWithPublicIP
                
                
                $listVMs.TenantName = $tenantID[$i].Directory
                $listVMs.SubscriptionName = $subscriptionID[$s].Name
                $vm = $vms |? -Property Id -eq $nics[$n].VirtualMachine.Id
                $listVMs.ResourceGroupName = $vm.ResourceGroupName
                $listVMs.VMName = $vm.Name
                Write-Host Start + $listVms.VMName
				$listVMs.OSType = $vm.StorageProfile.OsDisk.OsType
                $listVMs.PublicIP = (Get-AzureRmPublicIpAddress | Where-Object {$_.Id -eq $nics[$n].IpConfigurations.PublicIpAddress.Id}).IpAddress

                $tempvariable = $vm.Name
               
                foreach($VMstrings in $VMstring)
                {
                if($tempvariable.Contains($VMstrings)) #### Matching VM Name strings with all VM from all subscription
                {

                $vmWithPubIPs.Add($listVMs)  ###  Adding the values to CSV file
                Write-Host "Found a VM: $($vm.Name) with Public IP associated in Subscription: $($subscriptionID[$s].Name)"
                Write-Logging -Message "Found a VM: $($vm.Name) with Public IP associated in Subscription: $($subscriptionID[$s].Name)" -logfile ".\log.txt"
                
                }
                }
            }
        }
    }
    $vmWithPubIPs | Export-Csv "VirtualMachinesIPs.csv" -NoTypeInformation
    
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