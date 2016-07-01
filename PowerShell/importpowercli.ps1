function Import-PowerCLI {
	Add-PSSnapin vmware*
	if (Get-Item 'C:\Program Files (x86)' -ErrorAction SilentlyContinue) {
		. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
	}
	else {
		. "C:\Program Files\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
	}
}



    Import-Csv "C:\Users\sg0217865\Desktop\NewVMs.csv" -UseCulture | %{

        Get-OSCustomizationSpec $_.Customization | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $_.ip -SubnetMask $_.subnet -DefaultGateway $_.gw

        $vm=New-VM -Name $_.Name -Template $_.Template -Host $_.Host -Datastore $_.Datastore -Confirm:$false -RunAsync-OSCustomizationSpec $_.Customization

    }
