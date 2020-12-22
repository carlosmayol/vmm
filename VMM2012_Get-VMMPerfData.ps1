import-module virtualmachinemanager

#Reporting Hosts:
$vmhosts = Get-SCVMHost 

foreach ($vmhost in $vmhosts) {

$vmhostCPUPerfHistory = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter CPUUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmhostMEMPerfHistory = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter MemoryUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmhostNETIORPerfHistory = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter NetworkIOReceived -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmhostNETIOSPerfHistory = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter NetworkIOSent -TimeFrame Day | select -ExpandProperty PerformanceHistory #it shows no data BUG fixed UR2 for 2019
$vmhostStoragePerfHistory = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter StorageIOPSUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmhostCPUTimeSamples = Get-SCVMHOST $vmhost | Get-SCPerformanceData -PerformanceCounter CPUUsage -TimeFrame Day | select -ExpandProperty TimeSamples

[int]$max = $vmhostCPUTimeSamples.Count

    $result = for ($i=0; $i -lt $max; $i++)
    {
        [PScustomObject]@{
            Name=$vmhost.ComputerName
            CPUUsagePercent=$vmhostCPUPerfHistory[$i]
            MemUsageGB=$vmhostMEMPerfHistory[$i]
            NetRecMBps=$vmhostNETIORPerfHistory[$i]
            NetSentMBps=$vmhostNETIOSPerfHistory[$i]
            StorageMBps=$vmhostStoragePerfHistory[$i]
            Time=$vmhostCPUTimeSamples[$i]
            }
    }
    
    $result | ft -AutoSize #we can send this to a CSV file for graph out
}


#Reporting VMs      

$VMs= Get-SCVirtualMachine

foreach ($vm in $vms) {

$vmCPUPerfHistory = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter CPUUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmMEMPerfHistory = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter MemoryUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmNETIORPerfHistory = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter NetworkIOReceived -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmNETIOSPerfHistory = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter NetworkIOSent -TimeFrame Day | select -ExpandProperty PerformanceHistory 
$vmStoragePerfHistory = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter StorageIOPSUsage -TimeFrame Day | select -ExpandProperty PerformanceHistory
$vmCPUTimeSamples = Get-SCVirtualMachine $vm | Get-SCPerformanceData -PerformanceCounter CPUUsage -TimeFrame Day | select -ExpandProperty TimeSamples

[int]$max = $vmCPUTimeSamples.Count

    $result = for ($i=0; $i -lt $max; $i++)
    {
        [PScustomObject]@{
            Name=$vm.Name
            CPUUsagePercent=$vmCPUPerfHistory[$i]
            MemUsageGB=$vmMEMPerfHistory[$i]
            NetRecMBps=$vmNETIORPerfHistory[$i]
            NetSentMBps=$vmNETIOSPerfHistory[$i]
            StorageMBps=$vmStoragePerfHistory[$i]
            Time=$vmCPUTimeSamples[$i]
            }
    }
    
    $result | ft -AutoSize #we can send this to a CSV file for graph out
}
