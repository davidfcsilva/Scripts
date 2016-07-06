# Load Profile
C:\Users\dsilva\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

# Path for the report
$outputPath = "E:\Reporting\"

# Connect to vCenter Server
Connect-VIServer -name
 
Get-VIEvent -Start (Get-Date).AddDays(-1) -MaxSamples ([int]::MaxValue) |
Where {$_ -is [VMware.Vim.AlarmStatusChangedEvent] -and ($_.To -eq "Yellow" -or $_.To -eq "Red") -and $_.To -ne "Gray"} |
Select CreatedTime,FullFormattedMessage,@{N="Entity";E={$_.Entity.Name}},@{N="Host";E={$_.Host.Name}},@{N="Vm";E={$_.Vm.Name}},@{N="Datacenter";E={$_.Datacenter.Name}} |
Export-Csv "$outputPath\alarms.csv" -noTypeInformation -Delimiter ";"