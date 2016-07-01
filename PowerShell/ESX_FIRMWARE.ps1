Get-Datacenter | % {    
	$datacenter=$_  
	foreach($esx in Get-VMhost -Location $datacenter){  
		$esxcli = Get-EsxCli -VMHost $esx  
		$nic = Get-VMHostNetworkAdapter -VMHost $esx | Select -First 1 | select -ExpandProperty Name  
		$hba =Get-VMHostHBA -VMHost $esx -Type FibreChannel | where {$_.Status -eq "online"} |  Select -First 1 |select -ExpandProperty Name  
		Get-VMHostHBA -VMHost $esx -Type FibreChannel | where {$_.Status -eq "online"} |  
		Select @{N="Datacenter";E={$datacenter.Name}},  
			@{N="VMHost";E={$esx.Name}},  
			@{N="HostName";E={$($_.VMHost | Get-VMHostNetwork).HostName}},  
			@{N="version";E={$esx.version}},  
			@{N="Manufacturer";E={$esx.Manufacturer}},  
			@{N="Hostmodel";E={$esx.Model}},  
			@{Name="SerialNumber";Expression={$esx.ExtensionData.Hardware.SystemInfo.OtherIdentifyingInfo |Where-Object {$_.IdentifierType.Key -eq "Servicetag"} |Select-Object -ExpandProperty IdentifierValue}},  
			@{N="Cluster";E={  
				if($esx.ExtensionData.Parent.Type -ne "ClusterComputeResource"){"Stand alone host"}  
				else{  
					Get-view -Id $esx.ExtensionData.Parent | Select -ExpandProperty Name  
				}}},  
			Device,Model,Status,  
			@{N="WWPN";E={((("{0:X}"-f $_.NodeWorldWideName).ToLower()) -replace "(\w{2})",'$1:').TrimEnd(':')}},  
			@{N="WWN";E={((("{0:X}"-f $_.PortWorldWideName).ToLower()) -replace "(\w{2})",'$1:').TrimEnd(':')}},  
		  # @{N="Fnicvendor";E={$esxcli.software.vib.list() | ? {$_.Name -match ".*$($hba.hbadriver).*"} | Select -First 1 -Expand Vendor}},  
			@{N="Fnicvendor";E={$esxcli.hardware.pci.list() | where {$hba -contains $_.VMKernelName} |Select -ExpandProperty VendorName }},  
			@{N="fnicdriver";E={$esxcli.system.module.get("fnic").version}},  
			@{N="enicdriver";E={$esxcli.system.module.get("enic").version}},  
		  # @{N="Enicvendor";E={$esxcli.software.vib.list() | ? {$_.Name -match ".net.*"} | Select -First 1 -Expand Vendor}}  
			@{N="Enicvendor";E={$esxcli.hardware.pci.list() | where {$nic -contains $_.VMKernelName} |Select -ExpandProperty VendorName }}  
		  # @{N="Enicvendor";E={$esxcli.network.nic.list() | where {$vmnic.name -eq $_.vmnic1} | select -First 1 -ExpandProperty Description }}  
	}  
}   
