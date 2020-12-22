import-module virtualmachinemanager


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

        