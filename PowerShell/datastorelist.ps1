
#loading powercli environment


#change the parameter Server to your vCenter
$myvc=connect-viserver -Server "ldmevesxcenp001.ladbrokes.co.uk"

#you can get the datastores by the Hosts in your clusters
$myclusters=Get-Cluster -Server $myvc

$info2export=@()

foreach($cluster in $myclusters){
    $datastoresPerCluster=$cluster|Get-VMhost|Get-Datastore
    foreach($datastore in $datastoresPerCluster){
        $partialInfo=""|select ClusterName,DatastoreName,CapacitySpaceUsed,FreeSpace
        $partialInfo.ClusterName =$cluster.Name
        $partialInfo.DatastoreName =$datastore.Name
        #$partialInfo.ProvisionedSpace = ?
        $partialInfo.CapacitySpaceUsed =$datastore.CapacityGB
        $partialInfo.FreeSpace =$datastore.FreeSpaceGB
        $info2export+=$partialInfo
    }
}

#Export to csv in the path you want


$path="e:\reporting\datastoreList.csv"

$info2export|Export-Csv -Path $path -NoTypeInformation -UseCulture 