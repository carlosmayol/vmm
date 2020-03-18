$VM = Get-SCVirtualMachine -VMMServer localhost -Name "DC2008R2-01" | where {$_.VMHost.Name -eq "win2k8clu-lab2.lab.local"}
$OperatingSystem = Get-SCOperatingSystem -ID a4959488-a31c-461f-8e9a-5187ef2dfb6b | where {$_.Name -eq "64-bit edition of Windows Server 2008 R2 Enterprise"}
$UserRole = Get-SCUserRole -VMMServer localhost | where {$_.Name -eq "Administrator"}

$CPUType = Get-CPUType -VMMServer localhost | where {$_.Name -eq "3.60 GHz Xeon (2 MB L2 cache)"}

Set-SCVirtualMachine -VM $VM -Name "DC2008R2-01" -Description "" -OperatingSystem $OperatingSystem -Owner "LAB\vmmsvc" -UserRole $UserRole -CPUCount 1 -MemoryMB 512 -DynamicMemoryEnabled $true -DynamicMemoryMaximumMB 1500 -DynamicMemoryBufferPercentage 10 -MemoryWeight 5000 -VirtualVideoAdapterEnabled $false -CPUExpectedUtilizationPercent 20 -DiskIops 0 -CPUMaximumPercent 100 -CPUReserve 0 -NetworkUtilizationMbps 0 -CPURelativeWeight 100 -HighlyAvailable $false -NumLock $false -BootOrder "CD", "IdeHardDrive", "PxeBoot", "Floppy" -CPULimitFunctionality $false -CPULimitForMigration $false -CPUType $CPUType -Tag "(none)" -CostCenter "" -QuotaPoint 1 -JobGroup 98b8ba61-6b8c-4da0-8cb5-fb7151d7aeb5 -RunAsynchronously -StartAction TurnOnVMIfRunningWhenVSStopped -StopAction SaveVM -DelayStartSeconds 0 -BlockDynamicOptimization $false -EnableOperatingSystemShutdown $true -EnableTimeSynchronization $true -EnableDataExchange $true -EnableHeartbeat $true -EnableBackup $true -RunAsSystem -UseHardwareAssistedVirtualization $true 


