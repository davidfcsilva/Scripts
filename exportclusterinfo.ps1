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
$VCServerName = "ldmevesxcenp001.ladbrokes.co.uk"
$VC = Connect-VIServer $VCServerName
$TARGETDIR = "E:\Reporting"
$Report = @()
$Report2 = @()
$Report3 = @()
$ESXi = @()
$vmHOST = @()
$Clusters = @()
$VMcount = @()
$ESXinodes = @()
$vms = @()
$now = get-date -Format "dd-MMM-yyyy HH:mm"

# Lets organize our reporting shall we :-)
#if(!(test-path -path $TARGETDIR )){
    New-Item "E:\Reporting\$VC" -Type directory
#}
$ExportFilePath = "E:\Reporting\$VC\Export-ClusterInfo-host.csv"
$ExportFilePath2 = "E:\Reporting\$VC\Export-ClusterInfo-datastore.csv"

Function Percentcal {
    param(
    [parameter(Mandatory = $true)]
    [int]$InputNum1,
    [parameter(Mandatory = $true)]
    [int]$InputNum2)
    $InputNum1 / $InputNum2*100
}
 
$Clusters = Get-Cluster

ForEach ($ESXi in $Clusters) {
    Write-Host "## ESXI variable : " $ESXi "Before the Loop"
    $datastores = $ESXi |Get-VMHost | Get-Datastore
    write-host "VMHOST:" $ESXi "Datastore:" $datastores
    ForEach ($ds in $datastores) {
    if (($ds.Name -match “Shared”) -or ($ds.Name -match “”)) {
        $PercentFree = Percentcal $ds.FreeSpaceMB $ds.CapacityMB
        $PercentFree = “{0:N2}” -f $PercentFree
        $ds | Add-Member -type NoteProperty -name PercentFree -value $PercentFree
        }
    }

    write-host "Datastore:" $datastores
    $VMview = $ESXi | Get-VMHost| Select `
    @{Name="Cluster Name";Expression={$_."parent"}},`
    @{Name="ESXi  Host Name";Expression={$_."name"}},`
    @{N=“Number VM“;E={($_ | Get-VM).Count}},`
    @{N=“Number Datastores“;E={($_ | Get-datastore).Count}},`
    @{N=”Total Space GB”;E={($datastores.ExtensionData.Summary.Capacity | Measure-Object -Sum).Sum/1GB}},`
    @{N="Provisioned Space";E={((($datastores.ExtensionData.Summary.Capacity | Measure-Object -sum).Sum - ($datastores.ExtensionData.Summary.FreeSpace | Measure-Object -sum).Sum + ($datastores.ExtensionData.Summary.Uncommitted| Measure-Object -sum).Sum)/1GB)}},`
    @{N=”Available Space GB”;E={((($datastores.ExtensionData.Summary.Capacity | Measure-Object -sum).Sum – ($datastores.ExtensionData.Summary.FreeSpace | Measure-Object -sum).Sum)/1GB)}},`
    @{N="Percent Free";E={$datastores.PercentFree}},`
    numcpu,cputotalmhz,cpuusagemhz,`
    @{Name="Memory Total";E={[math]::Round($_."MemoryTotalGB"/1GB,0)}},`
    @{Name="Memory Usage";E={[math]::Round($_."MemoryUsageGB"/1GB,0)}},`
    #@{N=“Memory Provisioned“;E={($_ | get-vm | select memorygb |Measure-Object -Sum 'MemoryGB'|Select-Object sum)}},`
    @{N=“Memory Provisioned“;E={($_ | get-vm | select memorygb |Measure-Object -Sum).sum}},`
    version,$now
    $Report += $VMview
    Write-Host "#######################################################################"
    Write-Host "Total Space GB DS" $datastores.ExtensionData.Summary.Capacity
    Write-Host "Free Space GB DS" $datastores.ExtensionData.Summary.FreeSpace
    Write-Host "Uncommitted Space" $datastores.ExtensionData.Summary.Uncommitted
    Write-Host "Uncommitted Space Calculated" ($datastores.ExtensionData.Summary.Uncommitted | Measure-Object -sum).Sum
    Write-Host "Total Space Calculated"($datastores.ExtensionData.Summary.Capacity | Measure-Object -Sum).Sum / 1GB
    Write-Host "#######################################################################"
}

IF ($Report -ne "") {
$report | Export-Csv $ExportFilePath -NoTypeInformation
}
IF ($Report2 -ne "") {
$report2 | Export-Csv $ExportFilePath2 -NoTypeInformation
}
$VC = Disconnect-VIServer -Confirm:$False

# This now is the do the storage maths
#    $datastores = $ESXi |Get-VMHost | Get-Datastore
#    foreach ($datastore in $datastores) {
#        Get-VMHost -Location $ESXi |Get-Datastore | %{
#        $VMView2 = $_ | select Datacenter, Cluster, Name, Capacity, Provisioned, Available
#        $VMView2.Datacenter = $_.Datacenter
#        $VMView2.Cluster = $_.Name
#        $VMView2.Name = $_.Name
#        $VMView2.Capacity = [math]::Round($_.capacityMB/1024,2)
#        $VMView2.Provisioned = [math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2)
#        $VMView2.Available = [math]::Round($VMView2.Capacity - $VMView2.Provisioned,2)
        #write-host "### Storage Calculation ###"
#        Write-Host "### which host am I ?" $ESXi
#        Write-Host "### which datastore? " $datastore
        #Write-Host "### Where am I ?" $VMView2.Name
        #write-host "### Storage Capacity" $VMView2.Capacity
        #write-host "### Storage Provisioned" $VMView2.Provisioned
        #write-host "### Storage Freespace" $VMView2.Available
        #write-host "###########################"
        #$tdsc = $datastores | Select @{E={[Math]::Round(($_.ExtensionData.Summary.Capacity – $_.ExtensionData.Summary.FreeSpace)/1GB,0)}}
        #$tdsp = $datastores | select @{E={[Math]::Round(($_.ExtensionData.Summary.Capacity)/1GB,0)}}
        #$tdsa = $datastores | select @{E={[math]::Round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,0)}}
        #$tdsb = $datastores | select PercentFree
        
#   }