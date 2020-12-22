$a = get-vm | %{$_.Name}

$vmMac=@()

  
Write-Host ""
write-host " Analizando VMs" -ForegroundColor yellow

foreach ($vm in $a) 

{# Starting For1
	write-host "Analyzing the VM $vm"

	if (get-virtualnetworkadapter -VM $vm | ? {$_.VirtualNetworkAdapterType -ne "Synthetic"})

	{
	 $vmMAc += $vm # Exporto el nombre porque algunos objetos no están representado en nombre de la VM desde el virtualnetworkadapter
	 $vmMAc +=  get-virtualnetworkadapter -VM $vm | Select VirtualNetwork, Name, VirtualNetworkAdapterType
	}
	


} #Ending For1

$vmMac | ft -autosize