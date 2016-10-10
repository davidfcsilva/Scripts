 Get-Cluster -Name GI-MP-PRD-01 | Get-VM | % {

   [PSCustomObject] @{

       Name = $_.Name
       Host = $_.VMHost
       Datastore = $_ | Get-Datastore

   }

} | Sort-Object -Property Datastore