$objESX = Get-VMHost "gimppesx*"
 
# Get .NET views for host and storage system
$objViewESX = Get-View -id $objESX.id
$objViewESXstorageSys = Get-View -id $objViewESX.ConfigManager.StorageSystem
 
# Get FC HBAs
$HBAs = $objViewESXstorageSys.StorageDeviceInfo.HostBusAdapter | Where-Object {$_.Key -like "*FibreChannelHba*"}
#$HBAs
 
foreach ($hba in $HBAs) {
    # Enumerate LUNs
    $LUNcount = $objViewESXstorageSys.StorageDeviceInfo.MultiPathInfo.Lun.Length
    #Write-Host ("Enumerating $LUNcount LUNs on " + $hba.Device)
 
    for ($LUNidx = 0; $LUNidx -lt $LUNcount; $LUNidx++ ) {
        $objScsiLUN = $objViewESXstorageSys.StorageDeviceInfo.MultiPathInfo.Lun[$LUNidx]
        #$objScsiLUN
 
        # Enumerate paths on LUN
        $PathCount = $objScsiLUN.Path.Length
        #Write-Host ("Enumerating $PathCount paths on " + $objScsiLUN.Id)
 
        for ($PathIdx = 0; $PathIdx -lt $PathCount; $PathIdx++) {
            $objSCSIpath = $objViewESXstorageSys.StorageDeviceInfo.MultiPathInfo.Lun[$LUNidx].Path[$PathIdx]
            #Write-Host ($objSCSIpath.Name + " - " + $objSCSIpath.PathState)
 
            # Only care about one path, active on current HBA
            if (($objSCSIpath.PathState -eq "active") -and ($objSCSIpath.Adapter -eq $hba.Key)) {
                # Now get the disk that we want
                $objSCSIdisk = $objViewESXstorageSys.StorageDeviceInfo.ScsiLun | Where-Object{ ($_.CanonicalName -eq $objScsiLUN.Id) -and ($_.DeviceType -eq "disk") }
                #$objSCSIdisk
 
                # Now get the datastore info for disk
                $MountCount = $objViewESXstorageSys.FileSystemVolumeInfo.MountInfo.Length
                #Write-Host ("Enumerating $MountCount mounts on " + $objSCSIdisk.CanonicalName)
 
                for ($MountIdx = 0; $MountIdx -lt $MountCount; $MountIdx++ ) {
                    if ($objViewESXstorageSys.FileSystemVolumeInfo.MountInfo[$MountIdx].Volume.Type -eq "VMFS" ) {
                        $objVolume = $objViewESXstorageSys.FileSystemVolumeInfo.MountInfo[$MountIdx].Volume
                        #$objVolume
 
                        $ExtentCount = $objVolume.Extent.Length
                        #Write-Host ("Enumerating $ExtentCount mounts on " + $objVolume.Name)
 
                        for ($ExtentIdx = 0; $ExtentIdx -lt $ExtentCount; $ExtentIdx++ ) {
                            $objExtent = $objVolume.Extent[$ExtentIdx]
 
                            # Match extent name to disk name
                            if ($objExtent.DiskName -eq $objSCSIdisk.CanonicalName) {
                                Write-Host($objSCSIdisk.Vendor + " " + $objSCSIdisk.Model + " " + $objSCSIdisk.CanonicalName + "`t" + $objVolume.Name)
                            }
                        }
                    }
                }
            }
        }
    }
}
