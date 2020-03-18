#Setting Static IP Address on a VM Post Deployment 

$vm = Get-ScvirtualMachine -Name “NameOfVM"

$staticIPPool = Get-SCStaticIPAddressPool -Name "NameOfIPPool" 

Grant-SCIPAddress -GrantToObjectType "VirtualNetworkAdapter" -GrantToObjectID $vm.VirtualNetworkAdapters[0].ID -StaticIPAddressPool $staticIPPool

Set-SCVirtualNetworkAdapter -VirtualNetworkAdapter $vm.VirtualNetworkAdapters[0] -IPv4AddressType static