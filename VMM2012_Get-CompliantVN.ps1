get-vm | Get-SCVirtualNetworkAdapter | ft name, VirtualNetworkAdapterComplianceStatus, id -AutoSize

get-vm | Get-SCVirtualNetworkAdapter | ?{$_.VirtualNetworkAdapterComplianceStatus -eq "NonCompliant"} |  ft name, VirtualNetworkAdapterPortProfileSet, VirtualNetworkAdapterComplianceStatus, VirtualNetworkAdapterComplianceErrors -AutoSize

get-vm | Get-SCVirtualNetworkAdapter | ?{$_.VirtualNetworkAdapterComplianceStatus -eq "NonCompliant"} |Repair-SCVirtualNetworkAdapter