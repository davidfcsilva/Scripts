Connect-VIServer -Menu

Get-VMHost ukrl* | foreach {
    Start-VMHostService -HostService ($_ | Get-VMHostService | Where { $_.key -eq "TSM-SSH"})
}