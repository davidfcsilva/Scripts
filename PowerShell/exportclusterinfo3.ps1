$report = @()
#$VCServerName = "10.32.8.134"
#$VCServerName = "10.34.8.134"
#$VCServerName = "ukvcenterp01"
$VCServerName = "ldmevesxcenp001.ladbrokes.co.uk"
#$VC = Connect-VIServer $VCServerName

$clusterName = "*"
$now = get-date -Format "dd-MMM-yyyy HH:mm" 
$todayMidnight = (Get-date -Hour 0 -Minute 0 -Second 0).AddMinutes(-1)

$allvms = @()
$allhosts = @()
$vms = Get-Vm

foreach($cluster in Get-Cluster -Name $clusterName){
    
    $allhosts = @()
    $esx = $cluster | Get-VMHost

    foreach($vmHost in $esx){
        $hoststat = "" | Select HostName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin
        $hoststat.HostName = $vmHost.name
  
        #$statcpu = Get-Stat -Entity ($vmHost) -start (get-date).AddDays(-30) -Finish (Get-Date) -MaxSamples 10000 -stat cpu.usage.average
        #$statmem = Get-Stat -Entity ($vmHost) -start (get-date).AddDays(-30) -Finish (Get-Date) -MaxSamples 10000 -stat mem.usage.average
        $statcpu = Get-Stat -Entity ($vmHost) -start $todayMidnight.AddDays(-4) -Finish $todayMidnight.AddDays(-3) -stat cpu.usage.average |where{$_.instance -eq ""}
        $statmem = Get-Stat -Entity ($vmHost) -start $todayMidnight.AddDays(-4) -Finish $todayMidnight.AddDays(-3) -stat mem.usage.average |where{$_.instance -eq ""}
    
        $cpu = $statcpu | Measure-Object -Property value -Average -Maximum -Minimum
        $mem = $statmem | Measure-Object -Property value -Average -Maximum -Minimum
  
        $hoststat.CPUMax = $cpu.Maximum
        $hoststat.CPUAvg = $cpu.Average
        $hoststat.CPUMin = $cpu.Minimum
        $hoststat.MemMax = $mem.Maximum
        $hoststat.MemAvg = $mem.Average
        $hoststat.MemMin = $mem.Minimum
        $allhosts += $hoststat
    }
    #$allhosts | Select HostName, MemMax, MemAvg, MemMin, CPUMax, CPUAvg, CPUMin | Export-Csv "e:\reporting\$cluster-Hostsmetrics.csv" -noTypeInformation

    $ds = Get-Datastore -VMHost $esx | where {$_.Type -eq "VMFS" -and (Get-View $_).Summary.MultipleHostAccess}
        
    $row = "" | Select  "DC name",
                        "Cluster Name",

                        "No of ESXi Hosts",
                        "No of Defined VMs",
                        "No of Powered OFF VMs",
                        "VMs Allocation Ratio",
                        "Available VM Capacity - Host Down",

                        "Memory Usage Ratio (%)",
                        "Memory Allocattion Ratio (%)",
                        "Memory Allocattion Ratio (%) (Cluster Resillience)",
                        "CPU Allocation Ratio (%)",
                        "Storage Allocation Ratio (%)",
                        "Memory Max day (%)",
                        "Memory Avg Day (%)",
                        "Memory Min Day (%)",

                        "VM Memory Average (GB)",
                        "Memory Capacity Total (GB)",
                        "Memory Capacity Total (GB) - Host Down",
                        "Memory Allocated (GB)",
                        "Memory Available Total (GB)",
                        "Memory Last Day (GB)",
                        "Memory Max day (GB)",
                        "Memory Avg Day (GB)",
                        "Memory Min Day (GB)",
                        
                        "No of CPU Capacity",
                        "No of CPU Allocated",
                        "Total CPU (Mhz)",
                        "Allocated CPU (Mhz)",
                        "CPU Max Day (%)",
                        "CPU Avg Day (%)",
                        "CPU Min Day (%)",

                        "No of Datastores“,
                        "Total Disk Space (GB)",
                        "Allocated Disk Space (GB)",
                        "Available Disk Space (GB)",
                        
                        "Date:" 

    #$row."Vcenter" = $cluster.Uid.Split(':@')[1]
    $row."DC name" = (Get-Datacenter -Cluster $cluster).Name
    $row."Cluster Name" = $cluster.Name
    
    $row."No of ESXi Hosts" = @($esx).Count
    $row."No of Defined VMs" = ($esx  | Measure-Object -InputObject {$_.Extensiondata.Vm.Count} -Sum).Sum
    $row."No of Powered OFF VMs" = ($esx  | get-vm | where {($_.PowerState -eq "PoweredOff")}).Count
    $row."VMs Allocation Ratio" = "{0:f0}" -f ($row."No of Defined VMs" / $row."No of ESXi Hosts")
        
    $row."Memory Capacity Total (GB)" = "{0:f0}" -f (($esx | Measure-Object -Property MemoryTotalMB -Sum).Sum / 1KB)
    $row."Memory Capacity Total (GB) - Host Down" = "{0:f0}" -f (($row.'Memory Capacity Total (GB)' - ($row.'Memory Capacity Total (GB)' / $row.'No of ESXi Hosts')))
    $row."Memory Allocated (GB)" = "{0:f0}" -f ($esx|get-vm |where {($_.PowerState -eq "PoweredOn")} | select memorygb |Measure-Object memorygb -Sum).sum
    $row."Memory Available Total (GB)" = "{0:f0}" -f ($row.'Memory Capacity Total (GB)' - $row.'Memory Allocated (GB)')
    $row."Memory Last Day (GB)" = "{0:f0}" -f (($esx | Measure-Object -Property MemoryUsageMB -Sum).Sum / 1KB)
    $row."Memory Max Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property MemMax -sum).sum
    $row."Memory Avg Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property MemAvg -sum).Sum
    $row."Memory Min Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property MemMin -sum).Sum
    $row."Memory Max Day (GB)" = [float]$row.'Memory Capacity Total (GB)' * (($row.'Memory Max Day (%)' / $row.'No of ESXi Hosts' ) / 100 )
    $row."Memory Avg Day (GB)" = [float]$row.'Memory Capacity Total (GB)' * (($row.'Memory Avg Day (%)' / $row.'No of ESXi Hosts' ) / 100 )
    $row."Memory Min Day (GB)" = [float]$row.'Memory Capacity Total (GB)' * (($row.'Memory Min Day (%)' / $row.'No of ESXi Hosts' ) / 100 )
    

    $row.'Memory Usage Ratio (%)' =  "{0:f0}" -f (($row.'Memory Last Day (GB)' / $row.'Memory Allocated (GB)') * 100)
    $row.'Memory Allocattion Ratio (%)' =  "{0:f0}" -f (($row.'Memory Allocated (GB)' / $row.'Memory Capacity Total (GB)') * 100 )
    $row.'Memory Allocattion Ratio (%) (Cluster Resillience)' = "{0:f0}" -f (($row.'Memory Allocated (GB)' / (($row.'Memory Capacity Total (GB)' - ($row.'Memory Capacity Total (GB)' / $row.'No of ESXi Hosts')) - ($row.'Memory Capacity Total (GB)' / 100 * 5))) * 100)
            
    $row."No of CPU Capacity" = ($esx | Measure-Object -Property numcpu -Sum).Sum
    $row."No of CPU Allocated" =  "{0:f0}" -f ($esx |get-vm | select NumCPU | Measure-Object -Property NumCPU -Sum).Sum
    $row."CPU Allocation Ratio (%)" =  "{0:f0}" -f (($row."No of CPU Allocated" / $row."No of CPU Capacity") * 100)
    $row."Total CPU (Mhz)" = ($esx | Measure-Object -Property CpuTotalMhz -Sum).Sum
    $row."Allocated CPU (Mhz)" = ($esx | Measure-Object -Property CpuUsageMhz -Sum).Sum
    $row."CPU Max Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property CPUMax -sum).sum
    $row."CPU Avg Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property CPUAvg -sum).Sum
    $row."CPU Min Day (%)" = "{0:f0}" -f ($allhosts |Measure-Object -property CPUMin -sum).Sum 
    
    $row."No of Datastores“ = ($esx | Get-datastore).Count
    $row."Total Disk Space (GB)" = "{0:f0}" -f (($ds | where {$_.Type -eq "VMFS"} | Measure-Object -Property CapacityMB -Sum).Sum / 1KB)
    $row."Allocated Disk Space (GB)" = "{0:f0}" -f (($ds | Measure-Object -InputObject {$_.CapacityMB - $_.FreeSpaceMB} -Sum).Sum / 1KB)
    $row."Available Disk Space (GB)" = "{0:f0}" -f (($ds | Measure-Object -Property FreeSpaceMB -Sum).Sum / 1KB)
    $row."Storage Allocation Ratio (%)"=  "{0:f0}" -f (($row."Allocated Disk Space (GB)" / $row."Total Disk Space (GB)") * 100)

    $row."VM Memory Average (GB)" = "{0:f0}" -f ($row.'Memory Allocated (GB)' / $row.'No of Defined VMs')
    $row."Available VM Capacity - Host Down" = "{0:f0}" -f (($row.'Memory Capacity Total (GB) - Host Down' - $row.'Memory Allocated (GB)' ) / $row.'VM Memory Average (GB)')
                      
    $row."Date:" = $now
    $report += $row
} 
$report | Export-Csv "e:\reporting\Cluster-Report.csv" -NoTypeInformation -UseCulture