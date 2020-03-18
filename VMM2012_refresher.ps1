Get-SCVMHost | Where-Object -FilterScript {$_.GetRefresherMode() -eq "Legacy"} | Get-SCVirtualMachine | ForEach-Object -Process {Read-SCVirtualMachine -VM $_.Name}

Get-SCVMHost | Where-Object -FilterScript {$_.GetRefresherMode() -eq "Legacy"} | ForEach-Object -Process { Read-SCVirtualMachine -VMHost $_ }

New-ItemProperty 'HKLM:\software\microsoft\Microsoft System Center Virtual Machine Manager Server\Settings' -Name VMPropertiesEventAssitedUpdateInterval -Value 120 -PropertyType "DWord" -Force

# You can verify if the Host is using Event Based refresher mode by running –

Get-SCVMHost | ForEach-Object { "{0}, {1}, {2}" -f $_.Name, $_.HostCluster.Name, $_.GetRefresherMode()}

# If it returns Legacy mode, you can change –

$vmhost=get-scvmhost –computername COMPUTERNAME
$vmhost.ResetRefresherMode()

# This make take up to an hour to reflect the new mode 

# (Ref:  BEMIS 3001854)
