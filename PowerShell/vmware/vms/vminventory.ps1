 @"
===============================================================================
Title:         vminventory.ps1
Description:   Exports VM Information from vCenter into a .CSV file for importing into anything
Usage:         .\vminventory.ps1
Date:          10/15/2012
===============================================================================
"@
#### Get Virtual Center To Connect to:
$VCServerName = Read-Host "What is the Virtual Center name?"
$ExportFilePath = Read-Host "Where do you want to export the data?"
$VC = Connect-VIServer $VCServerName

$Report = @()
$VMs = get-vm |Where-object {$_.powerstate -eq "poweredoff"}
$Datastores = Get-Datastore | select Name, Id
$VMHosts = Get-VMHost | select Name, Parent
### Get powered off event time:
Get-VIEvent -Entity $VMs -MaxSamples ([int]::MaxValue) |
where {$_ -is [VMware.Vim.VmPoweredOffEvent]} |
Group-Object -Property {$_.Vm.Name} | %{
  $lastPO = $_.Group | Sort-Object -Property CreatedTime -Descending | Select -First 1
  $vm = Get-VIObjectByVIView -MORef $lastPO.VM.VM
  $report += New-Object PSObject -Property @{
    VMName = $vm.Name
    Powerstate = $vm.Powerstate
    OS = $vm.Guest.OSFullName
    IPAddress = $vm.Guest.IPAddress[0]
    ToolsStatus = $VMView.Guest.ToolsStatus
    Host = $vm.host.name
    Cluster = $vm.host.Parent.Name
    Datastore = ($Datastores | where {$_.ID -match (($vmview.Datastore | Select -First 1) | Select Value).Value} | Select Name).Name
    NumCPU = $vm.NumCPU
    MemMb = [Math]::Round(($vm.MemoryMB),2)
    DiskGb = [Math]::Round((($vm.HardDisks | Measure-Object -Property CapacityKB -Sum).Sum * 1KB / 1GB),2)
    PowerOFF = $lastPO.CreatedTime
    Note = $vm.Notes  }
}

$Report = $Report | Sort-Object VMName

if ($Report) {
  $report | Export-Csv $ExportFilePath -NoTypeInformation}
else{
  "No PoweredOff events found"
}

$VC = Disconnect-VIServer $VCServerName -Confirm:$False