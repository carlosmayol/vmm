$nodes = Get-VMHostCluster -Name $args[0] | %{$_.Nodes}
#$nodes = Get-VMHostCluster -Name ipbhitvhostcv11 | %{$_.Nodes}

$vmMemory = 0

write-host "Nodes inside the cluster" $nodes

foreach ($node in $nodes) 
{

Get-VMhost -computername $node | FT Name, TotalMemory, MemoryReserveMB, AvailableMemory -autosize

$vmhostmem = Get-VMhost -computername $node | Select AvailableMemory

$hostmem += $vmhostmem.AvailableMemory

$vms = get-vm -vmhost $node 

$vms | ft Name, Memory, DynamicMemoryEnabled -AutoSize

foreach ($vm in $vms) 
	{
	$vmMemory += $vm.memory
	}
}
write-host "All memory asigned to all VMs on this cluster is: $vmMemory MB"
write-host "-> HOST Available memory: $hostmem"