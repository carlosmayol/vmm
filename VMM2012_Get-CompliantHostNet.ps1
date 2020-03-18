Get-SCVMHost | %{$_.Name; Get-SCVirtualNetwork -VMHost $_ | ft vmhost, name, LogicalSwitch, logicalSwitchComplianceStatus, LogicalSwitchComplianceErrors -AutoSize}

Get-SCVMHost | %{$_.Name; Get-SCVirtualNetwork -VMHost $_ | ?{$_.logicalSwitchComplianceStatus -eq "NotCompliant"}} | ft vmhost, name, LogicalSwitch, logicalSwitchComplianceStatus, LogicalSwitchComplianceErrors -AutoSize

Get-SCVMHost | %{$_.Name; Get-SCVirtualNetwork -VMHost $_ | ?{$_.logicalSwitchComplianceStatus -eq "NotCompliant"}} | Repair-SCVirtualNetwork 


$vmhosts = Get-SCVMHost
foreach ($vmhost in $vmhosts)
    {
    $NotCompliant = $null
    $NotCompliant = Get-SCVirtualNetwork -VMHost $vmhost | Where-Object {$_.logicalSwitchComplianceStatus -eq "NotCompliant"}
    
    if ($NotCompliant -ne $null) {Repair-SCVirtualNetwork -VirtualNetwork $NotCompliant}
    }