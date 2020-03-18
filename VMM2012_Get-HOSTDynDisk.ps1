    $VhostName = Get-scVMHost

    $vmDisk=@()
	foreach ($vhost in $vhostname) {
        
        write-host $vhost
	
        $vmdisk += get-vm -vmhost $vhost | get-scvirtualhardDisk | where-object {$_.vhdtype -eq "DynamicallyExpanding"} | Select Name, Location, Size, MaximumSize
        
	   }
	#$vmdisk | ft Location, {$_.Size/1GB} , MaximumSize, Name -autosize

    $vmdisk | ft Location, @{Expression={$_.Size/1GB};Label="Size"},MaximumSize, Name -autosize 

