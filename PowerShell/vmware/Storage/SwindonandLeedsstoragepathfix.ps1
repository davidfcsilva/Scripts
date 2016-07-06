@"
===============================================================================
Title:         SwindonandLeedsstoragepathfix.ps1
Description:   Exports RDM Information from vCenter into a .CSV file for importing into anything
Usage:         .\SwindonandLeedsstoragepathfix.ps1
Date:          04/05/2016
Created by:    David Silva
===============================================================================
"@

Connect-VIServer -Menu
$ExportFilePath = "E:\Reporting\Export-RDMInfo.csv"

if (( Get-PSSnapin -name Vmware.Vimautomation.core -ErrorAction SilentlyContinue ) -eq $null ) {
 Add-PSSnapin vmware.vimautomation.core
 }

# Set Variable to 0
$report = @()

# Get vm list and there views
$vms = Get-VM | Get-View

# For each vm do the check
foreach($vm in $vms){
     foreach($dev in $vm.Config.Hardware.Device){
          if(($dev.gettype()).Name -eq "VirtualDisk"){
               if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or
               ($dev.Backing.CompatibilityMode -eq "virtualMode")){
                    $row = "" | select VMName, VMHost, HDDeviceName, HDFileName, HDMode, HDsize, HDDisplayName
                    $row.VMName = $vm.Name
                    $esx = Get-View $vm.Runtime.Host
                    $row.VMHost = ($esx).Name
                    $row.HDDeviceName = $dev.Backing.DeviceName
                    $row.HDFileName = $dev.Backing.FileName
                    $row.HDMode = $dev.Backing.CompatibilityMode
                    $row.HDSize = $dev.CapacityInKB
                    $row.HDDisplayName = ($esx.Config.StorageDevice.ScsiLun | where {$_.Uuid -eq $dev.Backing.LunUuid}).DisplayName
                    $report += $row
               }
          }
     }
}

# Store the report in a CSV file.
IF ($Report -ne "") {
$report | Export-Csv $ExportFilePath -NoTypeInformation
}