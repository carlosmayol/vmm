$VMHost = Get-SCVMHost -ComputerName "VMHost01"

$Compliance = Get-SCComplianceStatus -VMMManagedComputer $VMHost.ManagedComputerPS 

foreach($bsc in $Compliance.BaselineLevelComplianceStatus) {
    
    if ($bsc.Baseline.Name -eq "Security Baseline") {$Baseline = $bsc.Baseline; break}}

Start-SCComplianceScan -VMMManagedComputer $VMHost.ManagedComputer -Baseline $Baseline