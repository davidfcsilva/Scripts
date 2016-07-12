# Load Profile
if (!(test-path $profile )) 
{ 
    new-item -type file -path $profile -force 
} 
 

$cmd = 'if((Get-PSSnapin | Where-Object {$_.Name -eq "Microsoft.SharePoint.PowerShell"}) -eq $null) 
{ 
    Add-PSSnapIn "Microsoft.SharePoint.Powershell" 
}'

out-file -FilePath $profile -InputObject $cmd -Append

# Adds the base cmdlets
Add-PSSnapin VMware.VimAutomation.Core
# Add the following if you want to do things with Update Manager
Add-PSSnapin VMware.VumAutomation
# This script adds some helper functions and sets the appearance. You can pick and choose parts of this file for a fully custom appearance.
. "C:\Program Files\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-VIToolkitEnvironment.ps1"

# Connect to vCenter Server
Connect-VIServer 10.34.8.134

$dsTab = @{}
Get-datastore | %{
$dsTab[$_.Name] = $_.FreeSpaceGB
}

Get-vm | %{
$ds = $_.ExtensionData.Layout.Swapfile.Split(']')[0].TrimStart('[')
$_ | Select Name,@{N="Swap DS" ;E={$ds}},@{N="Free GB";E={[math]::Round($dsTab[$ds],1)}}
}