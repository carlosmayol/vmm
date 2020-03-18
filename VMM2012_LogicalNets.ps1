<#
http://blogs.technet.com/b/scvmm/archive/2013/09/18/here-s-a-script-for-vmm-2012-that-helps-you-create-logical-networks-vm-networks-and-logical-switches-in-the-proper-order.aspx

Based on this I went ahead and created a script that will help you create all of these components in the correct order so that you can avoid some of these mistakes. The only thing you need to do is deploy the logical switch to your hosts once the script is complete.
Let me make a disclaimer here first. The script is very basic. The purpose is to guide you to create the necessary infrastructure in the proper order. You can add more logic for error checking but I will leave this up to you. 
You will need to run this script on a SCVMM PowerShell console. Below is a list of what you will be asked when you run it:
1) Logical network name
2) If you want to enable network virtualization
3) Name of network site and what subnet to add as well as start and end IP for the IP pool
4) VM network name
5) If you want to enable network virtualization
6) Subnet, start IP and end IP for the private VM network
7) Name of the uplink port profile and native port profile
Once the process is done you can go to the properties of the hosts under virtual switches and select a new logical switch. At this point you select the information you created and SCVMM will create the virtual switches on the hosts.
Here’s the script:
#>


$logicalnetwork = Read-Host 'Provide a name for the logical network:' 
$response = Read-Host 'Do you want to enable virtualization? Y/N:' 
$responseUP = $response 
if ($responseUP -eq 'Y' -or $responseUP -eq 'y') 
{ 
$Enablenetvirt = $true 
} 
else 
{ 
$Enablenetvirt = $false 
} 
$subnet = Read-Host 'Provide the subnet in x.x.x.x/x format:' 
$ippoolname = Read-Host 'Provide a name for the ip pool in the logical network:' 
$startip = Read-Host 'Provide a starting IP in the' + $subnet + 'subnet:' 
$endIP = Read-Host 'Provide the ending IP in the' + $subnet + 'subnet:' 
$networksitename = Read-Host 'Provide a name for the network site with no spaces:' 
$vmnetname = Read-Host 'Provide a name for the virtual network:' 
$VMresponse = Read-Host 'Do you want to enable virtualization? Y/N:' 
$VMresponseUP = $VMresponse 
if ($VMresponseUP -eq 'Y' -or $VMresponseUP -eq 'y') 
{ 
if ($responseUP -ne 'Y' -or $responseUP -ne 'y') 
{ 
$Enablenetvirt = $true 
} 
$VMEnablenetvirt = $true 
$vmsubnetname = Read-Host 'Provide a name for the virtual network site:' 
$vmsubnet = Read-Host 'Provide the subnet for the vm network in x.x.x.x/x format:' 
$vmippoolname = Read-Host 'Provide a name for the ip pool in the logical network:' 
$vmstartip = Read-Host 'Provide a starting IP in the' + $vmsubnet + 'subnet:' 
$vmendIP = Read-Host 'Provide the ending IP in the' + $vmsubnet + 'subnet:' 
$usevirtualnetadapter = Read-Host 'Do you plan to create a virtual network adapter within the logical switch Y/N:' 
if ($usevirtualnetadapter -eq 'Y' -or $usevirtualnetadapter -eq 'y') 
{ 
$vnetworkadapter = Read-Host 'please provide a name for the no isolated virtual network:' 
} 
} 
else 
{ 
$VMEnablenetvirt = $false 
} 
$UPP = Read-Host 'Provide a name for the uplink port profile:' 
$NPP = Read-Host 'Provide a name for the Native port profile:' 
$logicalswitchname = Read-Host 'Provide a name for the logical switch:' 
$classificationname = Read-Host 'Provide a name for the classification:' 
new-sclogicalnetwork $logicalnetwork -EnableNetworkVirtualization $Enablenetvirt 
$allHostGroups = @() 
$allHostGroups += Get-SCVMHostGroup "All Hosts" 
$allSubnetVlan = @() 
$allSubnetVlan += New-SCSubnetVLan -Subnet $subnet -VLanID 0 
$networkdefinition = New-SCLogicalNetworkDefinition -Name $networksitename -LogicalNetwork $logicalNetwork -VMHostGroup $allHostGroups -SubnetVLan $allSubnetVlan 
# Gateways 
$allGateways = @() 
# DNS servers 
$allDnsServer = @() 
# DNS suffixes 
$allDnsSuffixes = @() 
# WINS servers 
$allWinsServers = @() 
New-SCStaticIPAddressPool -Name $ippoolname -LogicalNetworkDefinition $networkdefinition -Subnet $subnet -IPAddressRangeStart $startip -IPAddressRangeEnd $endIP -DefaultGateway $allGateways -DNSServer $allDnsServer -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixes 
IF ($VMEnablenetvirt -eq $false) 
{ 
$vmNetwork = New-SCVMNetwork -Name $vmnetname -LogicalNetwork $logicalNetwork -IsolationType "NoIsolation" 
Write-Output $vmNetwork 
} 
else 
{ 
$logicalNetworkVM = Get-SCLogicalNetwork -Name $logicalnetwork 
$vmNetwork = New-SCVMNetwork -Name $vmnetname -LogicalNetwork $logicalNetworkVM -IsolationType "WindowsNetworkVirtualization" -CAIPAddressPoolType "IPV4" -PAIPAddressPoolType "IPV4" 
Write-Output $vmNetwork 
$subnet = New-SCSubnetVLan -Subnet $vmsubnet 
$scvmsubnet = New-SCVMSubnet -Name $vmsubnetname -VMNetwork $vmNetwork -SubnetVLan $subnet 
# Gateways 
$allGateways = @() 
# DNS servers 
$allDnsServer = @() 
# DNS suffixes 
$allDnsSuffixes = @() 
# WINS servers 
$allWinsServers = @() 
New-SCStaticIPAddressPool -Name $vmsubnetname -VMSubnet $scvmsubnet -Subnet $vmsubnet -IPAddressRangeStart $vmstartip -IPAddressRangeEnd $vmendIP -DefaultGateway $allGateways -DNSServer $allDnsServer -DNSSuffix "" -DNSSearchSuffix $allDnsSuffixes -RunAsynchronously 
if ($usevirtualnetadapter -eq 'Y' -or $usevirtualnetadapter -eq 'y') 
{ 
$vmNetwork = New-SCVMNetwork -Name $vnetworkadapter -LogicalNetwork $logicalNetwork -IsolationType "NoIsolation" 
} 
} 
$definition = @() 
$definition += Get-SCLogicalNetworkDefinition -Name $networksitename 
New-SCNativeUplinkPortProfile -Name $UPP -Description "" -LogicalNetworkDefinition $definition -EnableNetworkVirtualization $VMEnablenetvirt -LBFOLoadBalancingAlgorithm "HyperVPort" -LBFOTeamMode "SwitchIndependent" 
New-SCVirtualNetworkAdapterNativePortProfile -Name $NPP -Description "" -AllowIeeePriorityTagging $false -AllowMacAddressSpoofing $false -AllowTeaming $false -EnableDhcpGuard $false -EnableIov $false -EnableIPsecOffload $false -EnableRouterGuard $false -EnableVmq $false -MinimumBandwidthWeight "0" 
$virtualSwitchExtensions = @() 
$virtualSwitchExtensions += Get-SCVirtualSwitchExtension -Name "Microsoft Windows Filtering Platform" 
$logicalSwitch = New-SCLogicalSwitch -Name $logicalswitchname -Description "" -EnableSriov $false -SwitchUplinkMode "NoTeam" -VirtualSwitchExtensions $virtualSwitchExtensions 
$nativeProfile = Get-SCNativeUplinkPortProfile -Name $UPP 
New-SCUplinkPortProfileSet -Name "custom UPP" -LogicalSwitch $logicalSwitch -RunAsynchronously -NativeUplinkPortProfile $nativeProfile 
New-SCPortClassification -Name $classificationname 
$portClassification = Get-SCPortClassification -Name $classificationname 
$nativeProfile = Get-SCVirtualNetworkAdapterNativePortProfile -Name $NPP 
New-SCVirtualNetworkAdapterPortProfileSet -Name $logicalswitchname -PortClassification $portClassification -LogicalSwitch $logicalSwitch -RunAsynchronously -VirtualNetworkAdapterNativePortProfile $nativeProfile
