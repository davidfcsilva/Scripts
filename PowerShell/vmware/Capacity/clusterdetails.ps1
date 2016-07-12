$vms = Get-VM
$stat = 'cpu.usage.average','mem.usage.average'
$start = (Get-Date).AddDays(-31)

$report = Get-Stat -Entity $vms -Start $start -Stat $stat -ErrorAction SilentlyContinue |

Group-Object -Property {$_.Entity.Name} | %{
	$cpu = $_.Group | where{$_.MetricId -eq 'cpu.usage.average'} | Measure-Object -Property Value -Average -Maximum -Minimum
	$mem = $_.Group | where{$_.MetricId -eq 'mem.usage.average'} | Measure-Object -Property Value -Average -Maximum -Minimum
	New-Object PSObject -Property @{
		Datacenter = Get-Datacenter -VM $_.Group[0].Entity | Select -ExpandProperty Name
		Cluster = Get-Cluster -VM $_.Group[0].Entity | Select -ExpandProperty Name
		VMHost = $_.Group[0].Entity.Host.Name
		Name = $_.Group[0].Entity.Name
		CpuMin = $cpu.Minimum
		CpuAvg = $cpu.Average
		CpuMax = $cpu.Maximum
		MemMin = $mem.Minimum
		MemAvg = $mem.Average
		MemMax = $mem.Maximum
	}
}
$report | Sort-Object -Property Datacenter,Cluster,VMHost,Name |
Export-Csv report.csv -NoTypeInformation -UseCulture 
