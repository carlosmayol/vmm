$hostprofile = Get-SCPhysicalComputerProfile -Name "WS 2012R2 Hyper-V Host"
$mac = (get-vm testvmbmr | Get-SCVirtualNetworkAdapter).MACAddress
$biosguid = (get-vm testvmbmr).biosguid
# DHCP need to assign IP and DNS able to contact PXE and VMM servers (by name)
# Home lab (needs DHCP static entry for DNS lab.local entries)
New-SCVMHost -ComputerName test -SMBiosGuid $BIOSGuid -VMHostProfile $hostprofile -ManagementAdapterMACAddress $MAC



get-vm testvmbmr2 | Set-SCVirtualMachine -FirstBootDevice "NIC,0"
$hostprofile = Get-SCPhysicalComputerProfile -Name "WS 2012R2 Hyper-V Host v2"
$mac = (get-vm testvmbmr2  | Get-SCVirtualNetworkAdapter).MACAddress
$biosguid = (get-vm testvmbmr2).biosguid
# DHCP need to assign IP and DNS able to contact PXE and VMM servers (by name)
# Home lab (needs DHCP static entry for DNS lab.local entries)
New-SCVMHost -ComputerName test2 -SMBiosGuid $BIOSGuid -VMHostProfile $hostprofile -ManagementAdapterMACAddress $MAC



Configure the BMC setting on an existing VMHOST:
$vmHost = Get-SCVMHost -Name "HOSTNAME"
$bmcRunAsAccount = Get-SCRunAsAccount -Name "Dell DRAC Account" -ID
Set-SCVMHost -VMHost $vmHost -BMCProtocol "IPMI" -BMCAddress "192.168.180.4" -BMCPort "623" -BMCRunAsAccount $bmcRunAsAccount