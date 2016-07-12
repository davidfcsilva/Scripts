$report = @()
$VCServerName = "10.32.8.134"
#$VCServerName = "10.34.8.134"
#$VCServerName = "ukvcenterp01"
#$VCServerName = "ldmevesxcenp001.ladbrokes.co.uk"
# $clusterName = "ldmevesxcenp001.ladbrokes.co.uk"  
$VC = Connect-VIServer $VCServerName
$clusterName = "*"
$now = get-date -Format "dd-MMM-yyyy HH:mm" 

foreach($cluster in Get-Cluster -Name $clusterName){
    $esx = $cluster | Get-VMHost    
    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS" -and (Get-View $_).Summary.MultipleHostAccess}
        
    $row = "" | Select  "DC name",
                        "Cluster Name",
                        "No of ESXi Hosts",
                        "No of VMs",
                        "Memory Capacity Total (GB)",
                        "Memory Allocated (GB)",
                        "Memory Available Total (GB)",
                        "Memory Last Day (GB)",
                        "Memory Peak day (GB)",
                        "Memory Avg Day (GB)",
                        "Memory Min Day (GB)",
                        "Memory Allocated Ratio)",
                        "No of CPU Capacity",
                        "No of CPU Allocated",
                        "CPU Allocation Ratio",
                        "CPU Overcommit",
                        "Total CPU (Mhz)",
                        "Allocated CPU (Mhz)",
                        "No of Datastores“,
                        "Total Disk Space (GB)",
                        "Available Disk Space (GB)",
                        "Allocated Disk Space (GB)",
                        "Date:" 

    #$row."Vcenter" = $cluster.Uid.Split(':@')[1]
    $row."DC name" = (Get-Datacenter -Cluster $cluster).Name
    $row."Cluster Name" = $cluster.Name
    
    $row."No of ESXi Hosts" = @($esx).Count
    $row."Nr of VMs" = @($esx | Get-VM).Count))
    #$row."Nr of VMs" = ($esx | Measure-Object -InputObject {$_.Extensiondata.Vm.Count} -Sum).Sum

    $row."Memory Capacity Total (GB)" = "{0:f0}" -f (($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum / 1KB)
    $row."Memory Allocated (GB)" = "{0:f0}" -f ($esx|get-vm | select memorygb |Measure-Object memorygb -Sum).sum
    $row."Memory Available Total (GB)" = "{0:f0}" -f (($esx | Measure-Object -InputObject {$_.MemoryTotalMB - $_.MemoryUsageMB} -Sum).Sum / 1KB)
    $row."Memory Used (GB)" = "{0:f0}" -f (($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum / 1KB)
    $row."Memory Peak day (GB)" = ""
    $row."Memory Last Day (GB)" = ""
    $row."Memory Avg Day (GB)" = ""
    $row."Memory Min Day (GB)" = ""
    $row."Memory Allocated Ratio)" = ""
    #$row."Memory Unalocatted (GB)" = "{0:f0}" -f ($esx | Measure-Object -InputObject {$_.MemoryTotalMB - ($esx | get-vm | select memorygb |Measure-Object memorygb -Sum).sum} -Sum).Sum
    #$row."Memory Unalocatted (GB)" = "{0:f0}" -f (($esx | Measure-Object -InputObject {$_.MemoryTotalMB - (($row."Memory Allocated (GB)") / 1KB)} -Sum).Sum / 1KB)
    #$row."Memory Overcommit (GB)" = "{0:f0}" -f (($esx | Measure-Object -InputObject {$_.
    
    $row."No of CPU Capacity" = ($esx | Measure-Object -Property numcpu -Sum).Sum
    $row."No of CPU Allocated" =  "{0:f0}" -f ($esx |get-vm | select NumCPU | Measure-Object -Property NumCPU -Sum).Sum
    $row."CPU Allocation Ratio" = ""
    $row."CPU Overcommit" =  "{0:N2}" -f ($row."Total VMs Cores" / $row."No of CPU" * 100)
    $row."Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
    #$row."Peak CPU" = ($esx |Measure-Object -Property cpumax -Sum).sum
    
    $row."Allocated CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
    #$row."Available CPU (Mhz)" = ($esx | Measure-Object -InputObject {$_.CpuTotalMhz - $_.CpuUsageMhz} -Sum).Sum

    $row."No of Datastores“ = ($esx | Get-datastore).Count
    $row."Total Disk Space (GB)" = "{0:f0}" -f (($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum / 1KB)
    $row."Available Disk Space (GB)" = "{0:f0}" -f (($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum / 1KB)
    $row."Allocated Disk Space (GB)" = "{0:f0}" -f (($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum / 1KB)
               
    $row."Date:" = $now
    $report += $row
} 
$report | Export-Csv "e:\reporting\Cluster-Report.csv" -NoTypeInformation -UseCulture