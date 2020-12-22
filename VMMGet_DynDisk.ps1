$vmmserver = get-vmmserver -computername "ipbhitcntrl101"

$clusters = Get-VMHostCluster 

foreach ($cluster in $clusters) {
    
    Write-Host ""
    write-host " Analizando cluster $cluster" -ForegroundColor yellow

    $VhostName = Get-VMHost -VMHostCluster $cluster

    $vmDisk=@()
	foreach ($vhost in $vhostname) {
        
        write-host $vhost
	
        $vmdisk += get-vm -vmhost $vhost | get-virtualhardDisk | where-object {$_.vhdtype -eq "DynamicallyExpanding"} | Select Name, Location, Size, MaximumSize
        
	   }
	$vmdisk | ft -autosize
	#To EXport to a txt file, rename below line
	#$vmDisk | Export-Csv $cluster.csv
}