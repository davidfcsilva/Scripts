 Get-Cluster |
Select-Object -Property Name,
@{Name="NumCpu"
  Expression={
    $_ | Get-VMHost |
    Measure-Object -Property NumCpu -Sum |
    Select-Object -ExpandProperty Sum
  }
},
@{Name="NumCpuAllocated";
  Expression={
    $_ | Get-VM |
    Measure-Object -Property NumCpu -Sum |
    Select-Object -ExpandProperty Sum
  }
}
@{Name="MemoryTotalMB"
  Expression={
    $_ | Get-VMHost |
    Measure-Object -Property MemoryTotalMB -Sum |
    Select-Object -ExpandProperty Sum
  }
}
@{Name="FreeSpaceMB"
  Expression={
    $_ | Get-VMHost |
    Measure-Object -Property FreeSpaceMB -Sum |
    Select-Object -ExpandProperty Sum
  }
}
