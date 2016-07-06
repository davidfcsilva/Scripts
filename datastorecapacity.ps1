@"
===============================================================================
Title:         ExportClusterInfo.ps1
Description:   Exports Cluster Information from vCenter into a .CSV file for importing into anything
Usage:         .\ExportClusterInfo.ps1
Date:          04/05/2016
Created by:    David Silva
===============================================================================
"@

# Variables
#$VCServerName = "10.32.8.134"
#$VCServerName = "ukvcenterp01"
#$VC = Connect-VIServer $VCServerName
$TARGETDIR = "E:\Reporting"

Function Percentcal {
    param(
    [parameter(Mandatory = $true)]
    [int]$InputNum1,
    [parameter(Mandatory = $true)]
    [int]$InputNum2)
    $InputNum1 / $InputNum2*100
}

$datastores = Get-Datastore -Name IL-*  | Sort Name
ForEach ($ds in $datastores) {
    if (($ds.Name -match “Shared”) -or ($ds.Name -match “”)) {
        $PercentFree = Percentcal $ds.FreeSpaceMB $ds.CapacityMB
        $PercentFree = “{0:N2}” -f $PercentFree
        $ds | Add-Member -type NoteProperty -name PercentFree -value $PercentFree
    }
}
$datastores | Select Name,`
                    @{N=”TotalSpaceGB”;E={[Math]::Round(($_.ExtensionData.Summary.Capacity)/1GB,0)}},`
                    @{N="Povisioned";E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,0)}},`
                    @{N="FreeSpace";E={[math]::Round(($_.ExtensionData.Summary.FreeSpace)/1GB,0)}},`
                    PercentFree | Export-Csv $TARGETDIR\datastorecapacity-$VCServerName.csv -NoTypeInformation
