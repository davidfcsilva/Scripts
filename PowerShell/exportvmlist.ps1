@"
===============================================================================
Title:         Export-VMInfo.ps1
Description:   Exports VM Information from vCenter into a .CSV file for importing into anything
Usage:         .\Export-VMInfo.ps1
Date:          03/05/2016
===============================================================================
"@
 
filter Get-FolderPath {
    $_ | Get-View | % {
        $row = "" | select Name, Path
        $row.Name = $_.Name
 
        $current = Get-View $_.Parent
#        $path = $_.Name # Uncomment out this line if you do want the VM Name to appear at the end of the path
        $path = ""
        do {
            $parent = $current
            if($parent.Name -ne "vm"){$path = $parent.Name + "\" + $path}
            $current = Get-View $current.Parent
        } while ($current.Parent -ne $null)
        $row.Path = $path
        $row
    }
}
 
$VCServerName = "10.34.8.134"
$VC = Connect-VIServer $VCServerName
#$VMFolder = "Workstations"
$ExportFilePath = "E:\Reporting\Export-VMInfo.csv"
 
$Report = @()
#$VMs = Get-Folder $VMFolder | Get-VM
$VMs = Get-VM
 
$Datastores = Get-Datastore | select Name, Id
$VMHosts = Get-VMHost | select Name, Parent
 
ForEach ($VM in $VMs) {
      $VMView = $VM | Get-View
      $VMInfo = {} | Select select parent,name,numcpu,cpuusagemhz,cputotatlmhz,memoryusagegb,memorytotalgb,version
            $Report += $VMInfo
}
$Report = $Report | Sort-Object parent
IF ($Report -ne "") {
$report | Export-Csv $ExportFilePath -NoTypeInformation
}
$VC = Disconnect-VIServer -Confirm:$False
