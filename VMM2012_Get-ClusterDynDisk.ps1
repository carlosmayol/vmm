$vmmserver = get-scvmmserver -computername "localhost"

$clusters = Get-scVMHostCluster 

foreach ($cluster in $clusters) {

    Write-Host ""
    write-host " Analizando cluster $cluster" -ForegroundColor yellow

    $VhostName = Get-scVMHost -VMHostCluster $cluster

    $vmDisk=@()
	foreach ($vhost in $vhostname) {
        
        write-host $vhost
	
        $vmdisk += get-vm -vmhost $vhost | get-scvirtualhardDisk | where-object {$_.vhdtype -eq "DynamicallyExpanding"} | Select Name, Location, Size, MaximumSize
        
	   }
	
	#$vmdisk | ft Location, {$_.Size/1GB} , MaximumSize, Name -autosize

    $vmdisk | ft Location, @{Expression={$_.Size/1GB};Label="Size"},MaximumSize, Name -autosize 


	$vmdisk | ft -autosize
	#To Export to a txt file, rename below line
	#$vmDisk | Export-Csv $cluster.csv
}