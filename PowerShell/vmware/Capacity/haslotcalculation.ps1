Connect-VIServer -menu
$SlotInfo = @()
Foreach ($Cluster in (Get-Cluster |Get-View)){
 $SlotDetails = $Cluster.RetrieveDasAdvancedRuntimeInfo()
 $Details = "" |Select Cluster, TotalSlots, UsedSlots, AvailableSlots, SlotNumvCPUs, SlotCPUMHz,SlotMemoryMB
 $Details.Cluster= $Cluster.Name
 $Details.TotalSlots = $SlotDetails.TotalSlots
 $Details.UsedSlots = $SlotDetails.UsedSlots
 $Details.AvailableSlots = $SlotDetails.UnreservedSlots
 $Details.SlotNumvCPUs = $SlotDetails.SlotInfo.NumvCpus
 $Details.SlotCPUMHz = $SlotDetails.SlotInfo.CpuMHz
 $Details.SlotMemoryMB = $SlotDetails.SlotInfo.MemoryMB
 $SlotInfo += $Details
}
$SlotInfo