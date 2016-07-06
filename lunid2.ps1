add-pssnapin VMware.VimAutomation.Core  
$VIServer = Connect-VIServer ukvcenterp01
$Hosts =
Get-VMHost $Hosts | Get-ScsiLun | Get-ScsiLunPath | Select Parent,Name,SCsiLunId,SanId #Export-Csv -Path e:\csv_file.csv -NoTypeInformation -NoClobber 
