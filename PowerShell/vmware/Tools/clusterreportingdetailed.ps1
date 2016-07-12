$reportdetail = @()
$clusterName = "MP-Production"

foreach($cluster in Get-Cluster -Name $clusterName)
	{
	foreach ($vmhost in ($cluster | Get-VMHost))
	{
		$VMView = $VMhost | Get-View
		$VMSummary = “” | Select HostName, ClusterName, MemorySizeGB, CPUSockets, CPUCores
		$VMSummary.HostName = $VMhost.Name
		$VMSummary.ClusterName = $Cluster.Name
		$VMSummary.MemorySizeGB = $VMview.hardware.memorysize / 1024Mb
		$VMSummary.CPUSockets = $VMview.hardware.cpuinfo.numCpuPackages
		$VMSummary.CPUCores = $VMview.hardware.cpuinfo.numCpuCores
		$reportdetail += $VMSummary
	}
}  
$reportdetail #| out-gridview
