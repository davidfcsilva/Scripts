###
###
$export_path = "E:\script\"
$export_datef = get-date -format yyyy-MM-dd-H-mm
$login_user = ""
$login_pwd = ""
$login_hosts = "ukvcenterp01"
##############################################################
### END
##############################################################
###Prepare variables
$end = get-date
###Check if we are connected to vCenter Server(s)
if($global:DefaultVIServers.Count -lt 1)
{
 Connect-VIServer $login_hosts -User $login_user -Password $login_pwd -AllLinked:$true
}
else
{
 echo "Already connected"
}
###Query all VMHosts
$result = Get-VMHost | select name,`
@{N="CpuUsageMhz"; E={[Math]::Round($_.CpuUsageMhz, 3)}}, @{N="CpuTotalMhz"; E={[Math]::Round($_.CpuTotalMhz, 3)}},`
@{N="CpuUsage%"; E={"{0:P0}" -f [Math]::Round($_.CpuUsageMhz/$_.CpuTotalMhz, 3)}},`
@{N="MemoryUsageGB"; E={[Math]::Round($_.MemoryUsageGB, 3)}}, @{N="MemoryTotalGB"; E={[Math]::Round($_.MemoryTotalGB, 3)}},`
@{N="MemoryUsage%"; E={"{0:P0}" -f [Math]::Round($_.MemoryUsageGB/$_.MemoryTotalGB, 3)}},`
@{N="VM Count"; E={$_.ExtensionData.vm.count}},`
@{N="Uptime"; E={(new-timespan $_.ExtensionData.Summary.Runtime.BootTime $end).days}},`
@{N="Overall Status"; E={$_.ExtensionData.OverallStatus}}, `
@{N="Configuration Status"; E={$_.ExtensionData.ConfigStatus}}`
| sort name
###Print out the result
$result | format-table -autosize | out-default
###Export the result to a CSV file
$result | export-csv -path "$export_path\ESXi-Host-Status-$export_datef.csv" -useculture
